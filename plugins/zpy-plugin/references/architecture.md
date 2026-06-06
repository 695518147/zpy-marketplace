# zpy-plugin Architecture

## Overview

zpy-plugin 融合 5 个开源项目核心能力，提供一站式 AI 工作流增强体验。

```
┌────────────────────────────────────────────────────┐
│                  zpy-flow (入口/路由)                │
├────────┬────────┬────────┬────────┬───────┬───────┤
│discover│research│ workflow│ agents │prompt │memory │
│(发现)   │(深度研究)│(编排)   │(协作)   │(优化)  │(记忆) │
├────────┴───┬────┴───┬────┴───┬────┴───┬───┴───────┤
│   Claude   │ DeerFlow│ Claude │ Agents │   Letta   │
│   Flow     │         │ Flow   │        │           │
└────────────┴─────────┴────────┴────────┴───────────┘
```

## Component Layers

### 1. Entry Layer (zpy-flow)
- 入口路由：解析用户意图，分发到对应 skill
- 支持自然语言路由、阶段路由、链式路由

### 2. Skill Layer (8 skills)
每个 skill 独立职责，通过 `name` 命名空间自动注册为插件命令

### 3. Agent Layer (3 agents)
自主执行特定领域任务，可被 skill 调用或独立触发

### 4. Infrastructure Layer
- **Hooks**: 事件驱动自动化（记忆保存、上下文恢复）
- **Settings**: 用户自定义配置（.local.md）
- **Memory**: 跨会话持久化（`~/.claude/memory/`）

## Skill Dependencies

```
zpy-flow
  ├── zpy-discover (无依赖)
  ├── zpy-deepresearch → zpy-memory
  ├── zpy-agents → zpy-workflow
  ├── zpy-prompt (无依赖)
  ├── zpy-memory (无依赖)
  ├── zpy-workflow (无依赖)
  └── zpy-integrate → (依赖外部资源)
```

## File Layout

```
zpy-plugin/
├── .claude-plugin/plugin.json    # 插件清单
├── skills/                        # 8 个技能
├── agents/                        # 3 个 Agent
├── hooks/hooks.json               # 3 个 Hook
├── references/                    # 参考文档
└── README.md
```
