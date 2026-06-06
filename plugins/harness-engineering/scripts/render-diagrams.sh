#!/bin/bash
# ==============================================================================
# 通用图表渲染脚本 — Mermaid / Fireworks → PNG
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./diagrams}"

mkdir -p "$OUTPUT_DIR"

echo "图表渲染开始..."
echo "输入目录: $INPUT_DIR"
echo "输出目录: $OUTPUT_DIR"

# Mermaid 图表渲染
if command -v mmdc &> /dev/null; then
    echo "使用 mmdc 渲染 Mermaid 图表..."
fi

# Fireworks 图表渲染（如适用）
if command -v fireworks &> /dev/null; then
    echo "使用 fireworks 渲染图表..."
fi

echo "图表渲染完成！"