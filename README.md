# LCC

## Project Structure
```
├── include                             # 頭文件
│   ├── common.h                        # 常用庫函數
│   └── dS                              # 相關數據結構定義
│       ├── hashTab.h
│       └── mtNode.h
├── Makefile                            # Makefile
├── README.md                           # this file
├── src                                 # 源文件
│   ├── dS                              # 相關數據結構操作
│   │   └── hashTab.c
│   ├── main.c                          # 主函數
│   ├── semantic                        # 在語法樹上進行語義分析
│   │   └── semantic.c
│   └── syntax-au                       # 進行詞法及語法分析並自動生成語法樹
│       ├── lexical.l
│       └── syntax.y
└── testcase                            # 測試用例
    └── test.cmm
```
