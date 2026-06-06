#!/bin/bash
# ==============================================================================
# Mermaid → PNG 渲染脚本
# ==============================================================================

set -e

if [ -z "$1" ]; then
    echo "用法: $0 <input.mmd> [output.png]"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.mmd}.png}"

if command -v mmdc &> /dev/null; then
    mmdc -i "$INPUT" -o "$OUTPUT" -w 1200
    echo "已渲染: $OUTPUT"
else
    echo "错误: mmdc 未安装 (npm install -g @mermaid-js/mermaid-cli)"
    exit 1
fi