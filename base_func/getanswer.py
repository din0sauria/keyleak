import json
import os

def load_json_file(file_path):
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def save_json_file(data, file_path):
    # 1. 取出目录部分
    dir_path = os.path.dirname(file_path)
    # 2. 目录不存在就递归创建
    if dir_path:
        os.makedirs(dir_path, exist_ok=True)
    # 3. 再写文件
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2)


def getanswer(file_path_single,output_list,output_path):

    input_file = file_path_single
    output_file_path=os.path.join(output_path,"answer.json")
    with open(input_file, 'r') as f:
        data = json.load(f)
    seen_items = set()
    globals= "./get_strings/node_modules/globals/"
    processed_data = []
    # glb_temp = load_json_file(globals+"temp.json")
    # for item in glb_temp:
    #     file_hash = item.get("file_hash", "")
    #     if file_hash not in output_list:continue
    #     value = item.get("value", "")
    #     unique_key = f"{file_hash}:{value}"
    #     if unique_key not in seen_items:
    #         seen_items.add(unique_key)
    #         processed_data.append({
    #             "file_hash": file_hash,
    #             "value": value})
    filters = set()
    # tmp_pack = load_json_file(globals+"pack.json")
    # for item in tmp_pack:
    #     key=item.get("file_hash", "")
    #     value=item.get("value", "")
    #     filters.add(f"{key}:{value}")
    for item in data:
        file_path = item.get("file", "")
        file_hash = file_path.split("/")[-1] if file_path else ""
        value = item.get("value", "").strip()
        if value[-1] == "\"" or value[-1] == "\'":  # 去掉末尾的引号
            value = value[:-1]
        unique_key = f"{file_hash}:{value}"
        if unique_key not in filters and unique_key not in seen_items:
            seen_items.add(unique_key)
            processed_data.append({
                "file_hash": file_hash,
                "value": value
            })

    save_json_file(processed_data,output_file_path)

    print(f"答案已保存到到 {output_file_path}")