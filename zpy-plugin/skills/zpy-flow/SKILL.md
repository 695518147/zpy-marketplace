---
name: zpy-flow
description: This skill should be used when the user asks to "flow", "流程导航", "流水线状态", "当前阶段", "下一步做什么", "show pipeline", "where am I", "flow status", or types "/flow" without arguments. Acts as the central routing hub for all zpy-skills.
argument-hint: "[可选: 阶段名(think/design/plan/build/test/review/ship/deploy/monitor)] [可选: 自然语言描述想做的事]"
allowed-tools:
  - Read
  - Write
  - TaskList
  - WebSearch
  - Agent
---

# zpy-flow

Central navigation hub for the development pipeline. Read the current project state, determine the right phase, and route the user to the correct zpy skill.

## Pipeline stages

```
THINK → DESIGN → PLAN → BUILD → TEST → REVIEW → SHIP → DEPLOY → MONITOR
```

### When user says /zpy-plugin:flow (no args)
1. Check for STATE.md, CLAUDE.md, or project context files to determine current phase
2. Display the full pipeline with current phase highlighted
3. Show what skills are available for the current phase
4. Suggest the next logical action

### When user says /zpy-plugin:flow <stage>

Route to the appropriate skill:

| User says | Route to | What happens |
|-----------|----------|-------------|
| `flow think` | `zpy-discover` | Research and explore options |
| `flow think "研究..."` | `zpy-deepresearch` | Deep research on the topic |
| `flow design` 或 `flow plan` | `zpy-workflow` | Design workflow/plan |
| `flow build` | `zpy-agents` roles "developer" | Assign developer agent |
| `flow build "实现..."` | `zpy-agents` | Route to agents for implementation |
| `flow test` | `zpy-agents` roles "tester" | Assign testing agent |
| `flow review` | `zpy-agents` roles "reviewer" | Assign reviewer agent |
| `flow ship` 或 `flow deploy` | `zpy-workflow` | Run release/deploy workflow |
| `flow monitor` | `zpy-deepresearch` | Analysis and monitoring |

### When user says /zpy-plugin:flow <natural language>

Parse the natural language to infer intent and route:
- "我想研究一下..." → delegate to `zpy-deepresearch`
- "帮我优化这个提示词..." → delegate to `zpy-prompt`
- "帮我做这几个任务..." → delegate to `zpy-workflow`
- "我需要几个角色同时做..." → delegate to `zpy-agents`

### When user says /zpy-plugin:flow <skill1>+<skill2>

Chain multiple skills together:
- `zpy-plugin:flow deepresearch+prompt` → research first, then optimize the resulting prompts
- `zpy-plugin:flow agents+workflow` → dispatch agents, then orchestrate their output into a workflow

## Cross-skill chaining

When chaining skills, preserve intermediate outputs by:
1. Saving the output of skill A to a temporary context
2. Passing it as context to skill B
3. Presenting the combined final result
