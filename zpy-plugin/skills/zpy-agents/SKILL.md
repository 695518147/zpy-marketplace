---
name: zpy-agents
description: This skill should be used when the user asks to "多 Agent", "agent 协作", "创建 Agent", "分配任务", "并行执行", "multi-agent", "assign agents", "agent team", "角色分工", or wants to decompose complex work across multiple specialized roles.
argument-hint: "[操作: create/assign/run/aggregate/list/roles] [Agent角色] [任务描述]"
allowed-tools:
  - Agent
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Read
  - Write
  - Edit
  - WebSearch
---

# zpy-agents

Orchestrate multiple specialized agents for parallel work, pipelined processing, debate-style evaluation, or review-based quality assurance.

## Collaboration modes

### Parallel mode (default)
Suitable for: independent subtasks that don't share intermediate results.

```
Dispatch N agents simultaneously, each working on a separate subtask.
→ Collect all results → Aggregate → Present to user
```

Procedure:
1. Decompose the task into independent subtasks
2. Dispatch each subtask via Agent tool (one per subtask)
3. Wait for all to complete
4. Aggregate results with conflict resolution

### Pipeline mode
Suitable for: sequential processing where each stage transforms the output.

```
Agent A (architect) → design doc
  → Agent B (developer) → implementation
    → Agent C (tester) → test results
```

Procedure:
1. Define the stage sequence
2. Run stage N, pass its output as context to stage N+1
3. Report each stage completion

### Debate mode
Suitable for: evaluating options or making decisions.

```
Assign 2-3 agents the same question with different perspectives
→ Compare and contrast their outputs
→ Synthesize a balanced conclusion
```

### Review mode
Suitable for: quality assurance.

```
Agent A produces output
Agent B, C review independently
→ Aggregate review feedback
→ Apply improvements (iterate if needed)
```

## Built-in roles

| Role | Expertise | Best for |
|------|-----------|---------|
| architect | System design, trade-offs | Planning phase |
| developer | Implementation, coding | Build phase |
| tester | QA, edge cases | Test phase |
| security-expert | Security review | Security audit |
| reviewer | Code quality, best practices | Code review |
| writer | Documentation, reports | Documentation |

## Output aggregation

After all agents complete:
1. Collect all outputs in a structured summary
2. Detect and flag conflicts between agents
3. Score each output for completeness and quality
4. Present a unified result to the user

## Related skills

- **`zpy-workflow`** — for orchestrating agents as part of a larger pipeline
- **`zpy-deepresearch`** — for research tasks that benefit from multi-agent decomposition
