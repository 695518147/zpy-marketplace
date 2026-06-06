# 🦾 zpy-plugin — 全能智能工作流引擎

融合五个开源项目的核心能力为一体，提供一站式 AI 工作流增强体验。

## 🔬 项目来源

| 项目 | 核心能力 | 在 zpy-plugin 中的体现 |
|------|---------|----------------------|
| [Letta (letta-ai/letta)](https://github.com/letta-ai/letta) | 记忆管理、状态持久化、上下文压缩 | `zpy-memory` + memory-agent |
| [Claude Flow (hgahlot/claude-flow)](https://github.com/hgahlot/claude-flow) | 工作流、统一命令路由、工具发现 | `zpy-flow` / `zpy-discover` / `zpy-integrate` |
| [Agents (wshobson/agents)](https://github.com/wshobson/agents) | 多 Agent 编排、跨平台插件市场 | `zpy-agents` + 3 个子 Agent |
| [Prompt Optimizer (linshenkx/prompt-optimizer)](https://github.com/linshenkx/prompt-optimizer) | 提示词优化、A/B 评估、模板管理 | `zpy-prompt` |
| [DeerFlow (bytedance/deer-flow)](https://github.com/bytedance/deer-flow) | 深度研究、DAG 工作流、沙箱执行 | `zpy-deepresearch` + `zpy-workflow` |

## 📦 技能一览

所有命令通过 `/zpy-plugin:zpy-xxx` 格式调用：

| 技能 | 调用方式 | 覆盖项目 | 核心功能 |
|------|---------|---------|---------|
| 🎯 `zpy-deepresearch` | `/zpy-plugin:zpy-deepresearch [主题]` | DeerFlow + Letta | 深度研究、多源调研、沙箱验证 |
| 🧠 `zpy-memory` | `/zpy-plugin:zpy-memory [操作] [内容]` | Letta | 记忆管理、上下文压缩、知识归档 |
| 🔄 `zpy-workflow` | `/zpy-plugin:zpy-workflow [操作] [名称]` | Claude Flow + DeerFlow | 任务流水线、DAG 编排、状态机 |
| 👥 `zpy-agents` | `/zpy-plugin:zpy-agents [操作] [角色] [任务]` | Agents + DeerFlow | 多 Agent 协作、任务分配 |
| ✏️ `zpy-prompt` | `/zpy-plugin:zpy-prompt [操作] [内容]` | Prompt Optimizer | 提示词优化、A/B 评估、模板 |
| 🧭 `zpy-flow` | `/zpy-plugin:zpy-flow [阶段]` | Claude Flow | 统一流程导航、命令路由 |
| 🔍 `zpy-discover` | `/zpy-plugin:zpy-discover [关键词]` | Claude Flow | 工具发现、趋势扫描 |
| 🔗 `zpy-integrate` | `/zpy-plugin:zpy-integrate [源] [地址]` | Claude Flow | 集成管理、配置合并 |

## 🤖 Agent 定义

| Agent | 描述 | 触发场景 |
|-------|------|---------|
| `zpy-deepresearch-agent` | 深度研究 Agent | 复杂研究、竞品分析、技术选型 |
| `zpy-memory-agent` | 记忆管理 Agent | 自动捕获决策、上下文管理、知识检索 |
| `zpy-workflow-agent` | 工作流编排 Agent | 多步骤任务、并行执行、进度追踪 |

## 🔌 Hooks 自动化

| Hook | 事件 | 功能 |
|------|------|------|
| `zpy-session-start` | SessionStart | 加载历史记忆，恢复工作流状态 |
| `zpy-decision-capture` | PostToolUse | 检测关键决策，提示保存到记忆 |
| `zpy-workflow-persist` | Stop | 会话结束时保存进行中的任务状态 |

## ⚙️ 用户配置

创建 `.claude/zpy-plugin.local.md` 自定义配置：

```yaml
---
memory:
  auto_compress_threshold: 70
  max_recall_results: 5
research:
  default_depth: "深入"
  default_output: "report"
workflow:
  default_retry: 1
agent:
  default_model: "claude-sonnet-4-6"
---
```

详见 `references/settings-guide.md`。

## 🚀 快速开始

### 安装

```bash
# 方法一：直接克隆到项目
git clone https://github.com/zpy/zpy-plugin.git .claude/plugins/zpy-plugin

# 方法二：从本地路径引用
# 在 .claude/settings.local.json 中添加：
# { "plugins": ["/Users/yinian/.claude/plugins/zpy-plugin"] }
```

### 使用示例

```bash
# 深度研究
/zpy-plugin:zpy-deepresearch 2024年主流 AI Agent 框架对比分析

# 提示词优化
/zpy-plugin:zpy-prompt optimize "写一个 Python REST API"

# 多 Agent 协作
/zpy-plugin:zpy-agents 并行 [架构设计, 代码实现, 单元测试] "实现用户注册模块"

# 工作流编排
/zpy-plugin:zpy-workflow create review-pipeline "代码审查自动化流水线"

# 记忆管理
/zpy-plugin:zpy-memory 保存 "用户偏好：喜欢 FastAPI 而非 Django"

# 统一流程导航
/zpy-plugin:zpy-flow 显示当前在哪一步

# 工具发现
/zpy-plugin:zpy-discover 推荐代码审查工具

# 技能集成
/zpy-plugin:zpy-integrate skill my-other-plugin:custom-skill
```

## 📂 项目结构

```
zpy-plugin/
├── .claude-plugin/
│   └── plugin.json          # 插件清单
├── commands/                  # 8 个斜杠命令入口
├── skills/                    # 8 个子技能（详细实现）
│   ├── zpy-deepresearch/     # 深度研究
│   ├── zpy-memory/           # 记忆管理
│   ├── zpy-workflow/         # 工作流编排
│   ├── zpy-agents/           # 多 Agent 协作
│   ├── zpy-prompt/           # 提示词优化
│   ├── zpy-flow/             # 统一流程导航
│   ├── zpy-discover/         # 工具发现
│   └── zpy-integrate/        # 集成管理
├── agents/                   # 3 个子 Agent
│   ├── zpy-deepresearch-agent.md
│   ├── zpy-memory-agent.md
│   └── zpy-workflow-agent.md
├── hooks/
│   └── hooks.json            # 事件驱动 Hook 配置
├── references/               # 参考文档
│   ├── architecture.md       # 架构总览
│   ├── skill-chaining.md     # 技能链式调用指南
│   └── settings-guide.md     # 用户配置说明
└── README.md
```

## 🔗 技能间协作

```
zpy-flow (入口)
├── → zpy-discover (探索发现)
├── → zpy-deepresearch (深度研究 → 利用 memory 保存结论)
│   └── → zpy-memory (保存研究发现)
├── → zpy-agents (多 Agent 执行)
│   └── → zpy-workflow (编排任务执行流程)
├── → zpy-prompt (优化过程中用到的提示词)
└── → zpy-integrate (集成外部能力)
```

> **注意**：`commands/` 已归档到 `commands-archived/`。`skills/` 是唯一规范命令来源。

## 📝 License

MIT

## 🙏 致谢

感谢以下开源项目的卓越工作：
- [Letta](https://github.com/letta-ai/letta) — Apache 2.0
- [Claude Flow](https://github.com/hgahlot/claude-flow) — MIT
- [Agents](https://github.com/wshobson/agents) — MIT
- [Prompt Optimizer](https://github.com/linshenkx/prompt-optimizer) — AGPL-3.0
- [DeerFlow](https://github.com/bytedance/deer-flow) — MIT
