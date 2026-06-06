#!/bin/bash
# ==============================================================================
# Harness Engineering — 依赖检查脚本
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FAILED=0

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Harness Engineering — 依赖检查        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}🔍 检查依赖...${NC}"
echo ""

# 核心工具链
echo -e "${BLUE}   [必装] 核心工具链${NC}"
for cmd in git node npm pandoc rsvg-convert python3; do
    if command -v "$cmd" &> /dev/null; then
        version=$($cmd --version 2>&1 | head -1)
        echo -e "   ${GREEN}✅${NC} $cmd: $version"
    else
        echo -e "   ${RED}❌${NC} $cmd: 未找到"
        FAILED=1
    fi
done
echo ""

# npm 全局包
echo -e "${BLUE}   [必装] npm 全局包${NC}"

# 检查 mmdc
if npx mmdc --version &> /dev/null; then
    version=$(npx mmdc --version 2>&1 | head -1)
    echo -e "   ${GREEN}✅${NC} mermaid-cli (mmdc): $version"
else
    echo -e "   ${RED}❌${NC} mermaid-cli (mmdc): 未安装 (npm install -g @mermaid-js/mermaid-cli)"
    FAILED=1
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 所有依赖已安装${NC}"
else
    echo -e "${RED}❌ 缺少依赖，请先安装${NC}"
    echo ""
    echo "安装指南："
    echo "  pandoc:       brew install pandoc"
    echo "  rsvg-convert:  brew install librsvg"
    echo "  mmdc:         npm install -g @mermaid-js/mermaid-cli"
fi

exit $FAILED
