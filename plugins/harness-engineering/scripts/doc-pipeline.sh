#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
echo "Document pipeline started..."
if command -v mmdc &> /dev/null; then
    cd "$PLUGIN_DIR"
    find . -name "*.md" -exec grep -l '```mermaid' {} \; | while read file; do
        echo "  Processing: $file"
    done
else
    echo "  mmdc not found"
fi
if command -v pandoc &> /dev/null; then
    cd "$PLUGIN_DIR"
    find . -name "*.md" | while read file; do
        docx_file="${file%.md}.docx"
        [ "$file" != "$docx_file" ] && pandoc "$file" -o "$docx_file" 2>/dev/null
    done
fi
echo "Document pipeline completed!"
