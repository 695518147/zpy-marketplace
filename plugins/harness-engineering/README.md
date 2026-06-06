# Harness Engineering Plugin

> AI Agent 工程纪律体系 — 通过 Claude Code Plugin 分发

## 概述

Harness Engineering 是一套开源 AI Agent 工程纪律体系，通过纯文本 Markdown 技能文件（SKILL.md）为 Claude Code 注入工程纪律。

**核心口号**：AI 编程缺的不是智力，是纪律，而纪律可以用纯文本分发。

## 功能

| Skill | 触发词 | 功能 |
|-------|--------|------|
| harness-entry | 会话启动、初始化 | 建立纪律基线，声明能力 |
| harness-brainstorming | 设计、方案、架构 | 9 步方案设计 |
| harness-document-generation | 写文档、生成 PRD | 模板遵循 + 配图 + md 转 docx |
| harness-systematic-debugging | 修 bug、调试 | 四阶段系统调试 |
| harness-code-review | review、审查 | 三阶段代码评审 |
| harness-implementation | 实现、开发 | TDD + 8 层编码模板 |
| harness-testing | 写测试、压测 | 单测 + E2E + 压测 |

## 安装

将此仓库作为 Claude Code 插件安装：

```bash
git clone https://github.com/deusyu/harness-engineering.git \
  ~/.claude/plugins/harness-engineering
```

然后在 Claude Code 中启用插件。

## 使用

### 自然语言触发

```
"帮我设计一个用户积分系统" → 自动进入 brainstorming 流程
"帮我写个技术方案文档" → 自动读取模板生成文档
"这个接口报 500 了帮我看看" → 自动进入系统调试流程
```

## 目录结构

```
harness-engineering/
├── .claude-plugin/
│   └── plugin.json          ← Plugin 清单
├── skills/                  ← 7 个 Skill
│   └── harness-*/
├── scripts/                 ← 工具脚本
│   ├── doc-pipeline.sh
│   └── ...
├── templates/               ← 文档模板
├── rules/                   ← 编码规范
├── knowledge/               ← 知识库
│   ├── core/               ← 核心流水线定义
│   ├── coding-standards/    ← 多技术栈编码规范
│   └── patterns/           ← 反模式/推荐模式
└── README.md               ← 你在这里
```

## 前置依赖

- git
- Node.js + npm
- pandoc（md → docx 转换）
- mmdc（Mermaid → PNG 渲染）
- rsvg-convert（SVG → PNG 转换）
- Python 3

## 与 Superpowers 的关系

Harness Engineering 与 [Superpowers](https://github.com/superpowers/) 互补：

| 维度 | Superpowers | Harness Engineering |
|------|-------------|-------------------|
| 定位 | 通用开发纪律 | 企业级全流程 |
| Skill 数量 | 14 个 | 7 个复合 Skill |
| 文档体系 | 无 | 完整模板 + 图表 |
| 语言 | 英文 | 中英双语触发词 |

两者可同时安装，不冲突。

## 更多信息

- [原学习档案](./concepts/) — 概念笔记
- [独立思考](./thinking/) — 思考文章
- [作品集](./works/) — 翻译与原创

## License

MIT