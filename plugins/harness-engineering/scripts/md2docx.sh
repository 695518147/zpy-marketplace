#!/bin/bash
# ==============================================================================
# MD 转 DOCX 转换脚本
# ==============================================================================

set -e

if [ -z "$1" ]; then
    echo "用法: $0 <input.md> [output.docx]"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.md}.docx}"

if command -v pandoc &> /dev/null; then
    pandoc "$INPUT" -o "$OUTPUT"
    echo "已转换: $OUTPUT"
else
    echo "错误: pandoc 未安装 (brew install pandoc)"
    exit 1
fi