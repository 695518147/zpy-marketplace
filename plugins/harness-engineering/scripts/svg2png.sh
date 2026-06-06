#!/bin/bash
# ==============================================================================
# SVG → PNG 导出脚本
# ==============================================================================

set -e

if [ -z "$1" ]; then
    echo "用法: $0 <input.svg> [output.png]"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.svg}.png}"

if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 1200 -h 800 "$INPUT" -o "$OUTPUT"
    echo "已转换: $OUTPUT"
else
    echo "错误: rsvg-convert 未安装 (brew install librsvg)"
    exit 1
fi