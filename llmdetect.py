import os
import sys
import json
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from base_func.base_func import get_files
import multiprocessing
from multiprocessing import Pool
import argparse
from tqdm import tqdm
from joblib import Parallel, delayed

# 初始化模型
def init_model(device_id=0):
    model_name = "Qwen/Qwen2.5-Coder-7B-Instruct-AWQ"
    
    # 指定特定的CUDA设备
    device_map = {"": f"cuda:{device_id}"}
    
    try:
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16,
            device_map=device_map
        )
    except Exception as e:
        print(f"使用device_map加载模型时出错: {e}")
        print("尝试使用传统方式加载模型...")
        # 如果device_map方式失败，使用传统方式加载
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16,
            low_cpu_mem_usage=True
        )
        model = model.to(f"cuda:{device_id}")
    
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    return model, tokenizer

# 检测单个文件中的复杂密钥
def detect_complex_keys_in_file(file_path, model, tokenizer, output_file=None):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        try:
            with open(file_path, 'r', encoding='latin-1') as f:
                content = f.read()
        except Exception as e:
            with open(file_path, 'rb') as f:
                content = f.read().decode('utf-8', errors='ignore')
    
    # 如果文件太大，只取部分内容
    max_content_length = 100000 #131,072个上下文token约100k代码
#     content="""def api_call(endpoint, header):
#     ......
#     print(f"Calling {endpoint} with header {header}")​
    
# api_call("https://api.example.com/data", "sec*******ret")"""
    content = content[:max_content_length]

    system_prompt = """
    你是一个构造密钥泄露检测助手，你需要阅读代码并给出部分密钥可能经过拼接、更长间距的上下文和特殊字符完整密钥，并以secret_key='value'的格式输出，若没有value可为空。例如：
    ## 样例一
    def connect(url, auth):
        print(f"Connecting to {url} with auth token: {auth}")​
    a = "sk-hm6******iob"
    b = "xbhczx"
    c = "bd*******bHwb"
    secret = a + b + c  
    connect("service.example.com", secret)
    答案是secret_key='sk-hm6******iobxbhczxbd*******bHwb'

    ## 样例二
    data: "secret_key=gna#3*******d&gdF4QaO&imei=000000000000000&version=2.1.54&_time=1614765847&heybox_id=15249824",
    答案是secret_key='gna#3*******d&gdF4QaO'
    """
    prompt=f"""
    请检测：
    {content}
    需要你根据理解告诉我密钥是多少，不要编写代码，按secret_key='value'的格式输出，若找不到value可为空。
    """
    
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt}
    ]
    
    text = tokenizer.apply_chat_template(
        messages,
        tokenize=False,
        add_generation_prompt=True
    )
    
    model_inputs = tokenizer([text], return_tensors="pt",truncation=True).to(model.device)
    
    generated_ids = model.generate(
        **model_inputs,
        max_new_tokens=512
    )
    
    generated_ids = [
        output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
    ]
    
    response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
    #print(content[:200],'>>>',response)
    # 解析响应中的密钥
    if "secret_key=" in response:
        result = {
            "file": file_path,
            "response": response,
            "detected_keys": extract_keys_from_response(response)
        }
        
        # 实时写入结果到文件
        if output_file and len(result["detected_keys"]) > 0:
            with open(output_file, 'a', encoding='utf-8') as f:
                f.write(json.dumps(result, ensure_ascii=False) + ',\n')
        
        return result
    
    return None

# 从LLM响应中提取密钥
def extract_keys_from_response(response):
    keys = []
    lines = response.split('\n')
    for line in lines:
        if "secret_key=" in line:
            # 提取密钥值
            try:
                key_part = line.split("secret_key=", 1)[1]
                if "'" in key_part:
                    key_value = key_part.split("'", 1)[1].split("'", 1)[0]
                elif '"' in key_part:
                    key_value = key_part.split('"', 1)[1].split('"', 1)[0]
                else:
                    key_value = key_part.strip()
                if key_value and key_value != "''" and key_value != '""':
                    keys.append(key_value)
            except:
                pass
    return keys

# 从src_filenames.txt读取文件列表
def get_source_files_from_txt(txt_path, base_path="/root/dino/keyleak/all_files_hash"):
    """
    从src_filenames.txt读取文件名并构造成完整路径
    """
    try:
        with open(txt_path, 'r', encoding='utf-8') as f:
            filenames = [line.strip() for line in f.readlines() if line.strip()]
        
        # 构造完整路径
        full_paths = [os.path.join(base_path, filename) for filename in filenames]
        
        # 过滤掉不存在的文件
        existing_files = [path for path in full_paths if os.path.exists(path)]
        
        print(f"从 {txt_path} 读取到 {len(filenames)} 个文件名")
        print(f"其中 {len(existing_files)} 个文件在 {base_path} 中存在")
        
        return existing_files
    except Exception as e:
        print(f"读取文件列表时出错: {e}")
        return []

# 处理文件批次
def process_file_batch(file_batch, device_id, output_file_prefix):
    """
    在指定的设备上处理一批文件，每个设备写入独立的文件
    """
    # 为每个GPU创建独立的输出文件
    output_file = f"{output_file_prefix}_gpu_{device_id}.json"
    
    # 初始化文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('[\n')
    
    results = []
    # 为每个批次初始化一次模型
    model, tokenizer = init_model(device_id)
    
    # 使用tqdm显示进度条
    for file_path in tqdm(file_batch, desc=f"GPU {device_id} 处理进度", leave=False):
        try:
            result = detect_complex_keys_in_file(file_path, model, tokenizer, output_file)
            if result and len(result["detected_keys"]) > 0:
                results.append(result)
        except Exception as e:
            print(f"处理文件 {file_path} 时出错: {e}")
    
    # 完成后关闭JSON数组
    with open(output_file, 'a', encoding='utf-8') as f:
        f.write('\n]')
    
    # 清理模型以释放内存
    del model
    del tokenizer
    torch.cuda.empty_cache()
    
    return results

# 将列表划分为n份
def split_list(lst, n):
    """
    将列表划分为n个子列表
    """
    k, m = divmod(len(lst), n)
    return [lst[i*k + min(i, m):(i+1)*k + min(i+1, m)] for i in range(n)]

# 多GPU并行处理函数
def process_files_with_multiple_gpus(file_list, num_gpus=4, output_file=None):
    """
    使用多个GPU并行处理文件
    """
    # 将文件列表划分为num_gpus个子列表
    file_batches = split_list(file_list, num_gpus)
    
    # 使用joblib并行处理，但确保每个进程独立加载模型
    results = Parallel(n_jobs=num_gpus, backend="loky")(
        delayed(process_file_batch)(file_batch, i, output_file) 
        for i, file_batch in enumerate(file_batches)
    )
    
    # 展平结果列表
    flattened_results = []
    for batch_result in results:
        flattened_results.extend(batch_result)
    
    return flattened_results

# 主函数
def main():
    parser = argparse.ArgumentParser(description='使用LLM检测复杂密钥')
    parser.add_argument('--path', dest='path', type=str, help='要检测的文件根路径', default="/root/dino/keyleak/all_files_hash")
    parser.add_argument('--size_limit', dest='size_limit', type=int, help='文件大小限制', default=100 * 1024* 1024)
    parser.add_argument('--output', dest='output', type=str, help='输出文件路径', default="./complex_keys_results.json")
    parser.add_argument('--num_gpus', dest='num_gpus', type=int, help='使用的GPU数量', default=4)
    
    args = parser.parse_args()
    
    print(f"正在扫描路径: {args.path}")
    print(f"使用GPU数量: {args.num_gpus}")
    
    # 从src_filenames.txt读取文件列表
    txt_file_path = "/root/dino/keyleak/src_filenames.txt"
    if os.path.exists(txt_file_path):
        file_list = get_source_files_from_txt(txt_file_path, args.path)
        print(f"从src_filenames.txt读取到 {len(file_list)} 个文件")
    else:
        print(f"未找到 {txt_file_path}，使用默认文件列表")
        file_list = get_files(args.path, args.size_limit)
    
    print(f"实际处理文件数: {len(file_list)}")
    
    # 初始化输出文件，创建JSON数组开始
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write('[\n')
    
    # 使用多个GPU并行处理文件
    print("正在使用多GPU并行处理文件...")
    results = process_files_with_multiple_gpus(file_list, args.num_gpus, args.output)
    
    
    print(f"检测完成，找到 {len(results)} 个可能包含复杂密钥的文件")
    print(f"结果已保存到: {args.output}")

if __name__ == '__main__':
    main()