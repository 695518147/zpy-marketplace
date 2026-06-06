---
name: zpy-workflow
description: This skill should be used when the user asks to "创建工作流", "编排任务", "pipeline", "流水线", "任务编排", "DAG", "工作流管理", "task automation", "workflow run", "并行执行", or wants to define and execute multi-step processes with dependencies.
argument-hint: "[操作: create/run/status/pause/resume/graph/list] [工作流名称] [可选: 任务列表]"
allowed-tools:
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - Bash
  - Read
  - Write
  - Edit
  - Agent
---

# zpy-workflow

Orchestrate multi-step task pipelines with DAG dependency management, parallel execution, state tracking, and error handling. Combines Claude Flow's development pipeline with DeerFlow's workflow engine.

## Workflow lifecycle

```
PENDING → RUNNING → [SUCCESS | FAILED | CANCELLED]
              ↓
          PAUSED → RESUMED → RUNNING
```

### create — define a workflow

Accept the user's description, decompose it into steps, and present the plan for confirmation:

```
Workflow: <name>
Steps:
1. <step A> — depends on: none
2. <step B> — depends on: 1
3. <step C> — depends on: 1
4. <step D> — depends on: 2, 3 (parallel-ready after 2,3)
```

For each step, create a TaskCreate entry so progress is visible in the task list.

### run — execute the workflow

Execute steps respecting dependencies:
- Steps with no dependencies: run immediately
- Independent steps: run in parallel using Agent tool or TaskCreate
- Dependent steps: await upstream completion before starting
- Use task dependencies: `TaskUpdate({id: "2", addBlockedBy: ["1"]})`

Track status via TaskList after each step.

### status — show progress

Display a visual progress bar and step-by-step status:
```
■ Step 1: Analysis      ✅ complete
■ Step 2: Design         🔄 running...
■ Step 3: Implementation ⬜ waiting (depends on 2)
■ Step 4: Testing        ⬜ waiting (depends on 1,3)
```

### pause/resume — manual control

On pause: mark current running step and save intermediate state.
On resume: restore state and continue from paused step.

### graph — visualize dependencies

Output a text-based DAG showing the dependency relationships:

```
A ──→ B ──→ D
 └──→ C ──┘
       └──→ E
```

## Built-in workflow templates

### Review pipeline
`lint → type-check → unit-test → code-review → integration-test`

### Release pipeline
`version-bump → build → test → package → publish → notify`

### Research pipeline
`requirement-analysis → info-gathering → analysis → report-draft → review`

### Custom
Ask the user for step definitions, or infer from their natural language description.

## Error handling

- Failed step: retry once automatically, then report with options (skip/abort/retry-modified)
- Dependent on failed step: mark as BLOCKED, explain what's needed
- Timeout: set per-step timeout based on estimated complexity
