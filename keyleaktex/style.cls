% \NeedsTeXFormat{LaTeX2e}
\ProvidesClass{style}[Template]

%%% ---- 载入Class ----- %%%
\LoadClass[a4paper,openany,oneside]{book} % A4大小，book布局
\PassOptionsToPackage{quiet}{fontspec}
\RequirePackage[AutoFakeBold=true,AutoFakeSlant=true]{xeCJK}
\RequirePackage[zihao=-4,UTF8,heading=true]{ctex}
\RequirePackage{xeCJKfntef}
\RequirePackage{eso-pic}       
%%% ---- 定义页边距 ----- %%%
\RequirePackage{geometry}
\geometry{left=2cm,right=2cm,top=2.54cm,bottom=2.54cm,includefoot,xetex}
\setlength{\headheight}{18.5pt}

\RequirePackage{fancyhdr}             % 页眉页脚宏包
\renewcommand{\headrulewidth}{0.5pt}  % 页眉线宽
\renewcommand{\footrulewidth}{0pt}    % 页脚线宽


% 页眉线淡化
% \renewcommand{\headrule}{
%   \color{gray}
%   \hrule width\headwidth height\headrulewidth \vskip-\headrulewidth
% }


% 页眉页脚样式
\fancypagestyle{plain}{
    \fancyhf{}
    \fancyhead[C]{\vspace{4pt}\textcolor{black}{\zihao{5}DataCon2025软件供应链安全赛道题解}}
    \fancyfoot[C]{\zihao{5}\thepage}
}


% 含有页眉但无页码的样式
\fancypagestyle{noPageNum}{
    \fancyhf{} 
    \fancyhead[C]{\vspace{4pt}\textcolor{black}{\zihao{5}DataCon2025软件供应链安全赛道题解}}
}

\pagestyle{plain}

%%% ---- 定义标题和段落样式 ----- %%%
% 定义1.5倍行距
\RequirePackage{setspace}
\renewcommand{\baselinestretch}{1.5}
% 设置各个标题样式
% \ctexset{chapter={format={\centering \heiti \zihao{-2}}, number={   % 各章标题 黑体小2号 // 修改：标题和数字字号一致 
%     \arabic{chapter}},name={,},afterskip={1em},beforeskip={0em}}}
\renewcommand{\thesection}{\arabic{section}}
\ctexset{section={format={\raggedright \heiti \zihao{4}}}}          % 一级标题 黑体 4号
\ctexset{subsection={format={\raggedright \heiti \zihao{-4}}}}      % 二级标题 黑体小4号
\ctexset{subsubsection={format={\raggedright \heiti \zihao{-4}}}}   % 三级标题 黑体小4号


% 目录样式设置
\RequirePackage{tocloft}
\setcounter{tocdepth}{2}        % 目录层级数
\setcounter{secnumdepth}{3}     % 标题层级数

\renewcommand{\cfttoctitlefont}{\hfill\heiti\zihao{-2}} % 目录标题 黑体小 2 号
\renewcommand{\contentsname}{目\hspace{2em}录}
\renewcommand{\cftaftertoctitle}{\hfill}
\setlength\cftbeforetoctitleskip{0cm}
\setlength\cftaftertoctitleskip{0ex}

\renewcommand{\cftdot}{$\cdot$}
\renewcommand{\cftdotsep}{1}  % 点间距
\renewcommand{\cftchapdotsep}{\cftdotsep}

\renewcommand\cftchapfont{\bfseries\fangsong\zihao{4}} % 目录章标题 黑体 4 号
\renewcommand\cftsecfont{\songti\zihao{-4}}
\renewcommand\cftsubsecfont{\songti\zihao{-4}}
\renewcommand\cftsubsubsecfont{\songti\zihao{-4}}
\renewcommand\cftchappagefont{\bfseries\fangsong\zihao{-4}} % 目录页码字体
\renewcommand\cftsecpagefont{\songti\zihao{-4}}
\renewcommand\cftsubsecpagefont{\songti\zihao{-4}}
\renewcommand\cftsubsubsecpagefont{\songti\zihao{-4}}

\renewcommand\cftchapafterpnum{\vskip5pt}
\renewcommand\cftsecafterpnum{\vskip3pt}
\renewcommand\cftsubsecafterpnum{\vskip2pt}
\setlength{\cftsecindent}{1.85em}
\setlength{\cftsubsecindent}{3.7em}
\setlength{\cftsubsubsecindent}{7.4em}

% 生成目录
\def\makecontents{
    % ------- 目录部分 -------
    \tableofcontents
    
    \cleardoublepage
    \pagenumbering{arabic}            % 切换为阿拉伯数字
    \setcounter{page}{1}

    \renewcommand{\baselinestretch}{1}\normalsize
    \baselineskip=23pt                % 正文行距为 23 磅
}


%%% ---- 图表标题设置 ----- %%%
\RequirePackage[labelsep=quad]{caption}     % 序号之后空一格写标题
\captionsetup[table]{font={small},labelfont=bf,textfont=normalfont}
\captionsetup[figure]{font={small},labelfont=bf,textfont=normalfont}
\renewcommand\figurename{\bf\songti\zihao{5} 图}
\renewcommand\tablename{\songti\bf\zihao{5} 表}

% 使用tabularx创建占满宽度的表格
\RequirePackage{tabularx, makecell}
\newcolumntype{L}{X}
\newcolumntype{C}{>{\centering \arraybackslash}X}
\newcolumntype{R}{>{\raggedleft \arraybackslash}X}

\RequirePackage{longtable}  % 做长表格的包
\RequirePackage{booktabs}   % 做三线表的包
\RequirePackage{etoolbox}   % 用于修改表格的包
\AtBeginEnvironment{tabular}{\zihao{5}} % 表格字体大小 5 号
\AtBeginEnvironment{tabularx}{\zihao{5}}

% 列表样式
\RequirePackage{enumerate, enumitem}
\setlist{noitemsep}

% 修改脚注
\makeatletter%
\long\def\@makefnmark{%
\hbox {{\normalfont \textsuperscript{\circled{\@thefnmark}}}}}%
\makeatother
\makeatletter%
\long\def\@makefntext#1{%
  \parindent 1em\noindent \hb@xt@ 1.8em{\hss \circled{\@thefnmark}}#1}%
\makeatother
\skip\footins=10mm plus 1mm
\footnotesep=6pt
\renewcommand{\footnotesize}{\songti\zihao{5}}
\renewcommand\footnoterule{\vspace*{-3pt}\hrule width 0.3\columnwidth height 1pt \vspace*{2.6pt}}

\newcommand*\circled[1]{\tikz[baseline=(char.base)]{%
\node[shape=circle,draw,inner sep=0.5pt] (char) {#1};}} % 圆圈数字①

%%% ---- 引入宏包 ----- %%%
\RequirePackage{amsmath, amssymb}
\RequirePackage[amsmath,thmmarks]{ntheorem}  % 定理
\RequirePackage{graphicx, subcaption}
\RequirePackage{listings}                    % 代码段
\RequirePackage{algorithmic}                 % 算法代码
\RequirePackage[ruled,linesnumbered,vlined]{algorithm2e}
\RequirePackage{tikz, pgfplots}              % 绘图
\pgfplotsset{compat=1.8}
\RequirePackage{fontspec, color, url, array}
\RequirePackage{float}                       % 浮点
\RequirePackage{enumitem}                    % 缩紧列表
\RequirePackage{multirow}                    % 多列表格
\RequirePackage{txfonts}                     % Times 风格（数学）字体

%%% ---- 定义字体 ----- %%%
\renewcommand{\normalsize}{\zihao{-4}}         % 正常字号
% 设置英文字体为 Times New Roman
\setmainfont[Ligatures=Rare]{Times New Roman}
\setsansfont[Ligatures=Rare]{Times New Roman}
\setmonofont[Ligatures=Rare]{Times New Roman}

\renewcommand{\algorithmcfname}{算法}          % 算法两字用中文显示

%%% ---- 数学定理样式 ----- %%%
\theoremstyle{plain}
\theoremheaderfont{\heiti}
\theorembodyfont{\songti} \theoremindent0em
\theorempreskip{0pt}
\theorempostskip{0pt}
\theoremnumbering{arabic}
\newtheorem{theorem}{\hspace{2em}定理}[section]
\newtheorem{definition}{\hspace{2em}定义}[section]
\newtheorem{lemma}{\hspace{2em}引理}[section]
\newtheorem{corollary}{\hspace{2em}推论}[section]
\newtheorem{proposition}{\hspace{2em}性质}[section]
\newtheorem{example}{\hspace{2em}例}[section]
\newtheorem{remark}{\hspace{2em}注}[section]

\theoremstyle{nonumberplain}
\theoremheaderfont{\heiti}
\theorembodyfont{\normalfont \rm \songti}
\theoremindent0em \theoremseparator{\hspace{1em}}
\theoremsymbol{$\square$}
\newtheorem{proof}{\hspace{2em}证明}


%%% ---- 参考文献设置 ----- %%%
\ctexset{
  bibname = {\zihao{3}参考文献},      % 字号不变
  chapter/beforeskip = -20pt plus 1pt minus 1pt,  % ← 关键句
}
\RequirePackage{natbib}
\RequirePackage[sort&compress]{gbt7714}
\bibliographystyle{gbt7714-numerical}



\RequirePackage[hidelinks]{hyperref} % 引用

\makeatletter   % 为了支持gbt7714标准
\newcommand{\rawcite}[1]{%
  \begingroup
    \setcitestyle{numbers,square,comma}
    \cite{#1}%
    \setcitestyle{}
  \endgroup
}
\makeatother


\renewcommand{\eqref}[1]{\textup{{\normalfont（\ref{#1}）\normalfont}}} % 公式引用使用中文括号

% 清除公式上下间距
\AtBeginDocument{
	\setlength{\abovedisplayskip}{6pt}
	\setlength{\belowdisplayskip}{6pt}
	\setlength{\abovedisplayshortskip}{0pt}
	\setlength{\belowdisplayshortskip}{0pt} 
}

\graphicspath{{assert/}} % 图片文件路径

% --------------------------------------

%%% ---- 自定义命令 ----- %%%

%%% ---- 封面 ----- %%%
\makeatletter
\def\ctitle#1{\def\@ctitle{#1}}\def\@ctitle{}         % 题目
\def\cschool#1{\def\@cschool{#1}}\def\@cschool{}      % 院系
\def\cmajor#1{\def\@cmajor{#1}}\def\@cmajor{}         % 专业
\def\cauthor#1{\def\@cauthor{#1}}\def\@cauthor{}      % 作者
\def\cadvisor#1{\def\@cadvisor{#1}}\def\@cadvisor{}   % 老师
\def\cdate#1{\def\@cdate{#1}}\def\@cdate{}            % 日期
\def\cnumber#1{\def\@cnumber{#1}}\def\@cnumber{}      % 学号

% 论文标题页
\def\maketitlepage{
  \thispagestyle{empty}
  \begin{center}
    \begin{figure}
        \vspace{6em}
        \centering
        \includegraphics[width=0.35\linewidth]{figures/whulogo.pdf}
    \end{figure}
    \par \vspace*{1em}
    {\fangsong \zihao{2} \bfseries{}}
    \par \vspace{3em}
    \begin{minipage}[c][6cm]{\textwidth}
        \setlength{\baselineskip}{32pt} 
        \centering {\kaishu \zihao{1} \@ctitle}
    \end{minipage}
    \par \vspace{3em}
    {\songti 
      \begin{tabular}{cc}
        \zihao{4}\makebox[3.59cm][l]{姓\hspace{2em}名\hspace{1ex}：} & \zihao{4}\makebox[3.59cm][c]{\@cauthor}   \\[1.5ex]
        \zihao{4}\makebox[3.59cm][l]{学\hspace{2em}号\hspace{1ex}：} & \zihao{4}\makebox[3.59cm][c]{\@cnumber}   \\[1.5ex]
        \zihao{4}\makebox[3.59cm][l]{专\hspace{2em}业\hspace{1ex}：} & \zihao{4}\makebox[3.59cm][c]{\@cmajor}    \\[1.5ex]
        \zihao{4}\makebox[3.59cm][l]{学\hspace{2em}院\hspace{1ex}：} & \zihao{4}\makebox[3.59cm][c]{\@cschool}   \\[1.5ex]
        \zihao{4}\makebox[3.59cm][l]{指导教师\hspace{1ex}：}          & \zihao{4}\makebox[3.59cm][c]{\@cadvisor}  \\[1.5ex]
      \end{tabular}}
    \par \vfill
    {\songti \zihao{4} \@cdate}
  \end{center}
  \clearpage
}
% 添加logo到封面的命令
\newcommand\addlogotitle{%
    \AddToShipoutPictureBG*{%
        \AtPageUpperLeft{%
            \hspace{3cm}%
            \raisebox{-3cm}{%
                \includegraphics[width=8cm]{logo.png}
            }
        }
    }
}

% 重定义maketitle，在生成标题前添加logo
\let\oldmaketitle\maketitle
\renewcommand\maketitle{%
\addlogotitle%
\oldmaketitle%
}