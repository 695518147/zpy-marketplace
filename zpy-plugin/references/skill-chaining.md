# Skill Chaining Reference

zpy-plugin 的多个 skill 可以串联使用，形成完整的工作流。

## Common Chains

### Research → Save
```
zpy-deepresearch "主题" → zpy-memory save
```
调研结果自动保存到长期记忆。

### Research → Implement
```
zpy-deepresearch "技术方案" → zpy-agents 并行 [开发]
```
先研究方案，再用 Agent 并行实现。

### Prompt → Workflow
```
zpy-prompt optimize "系统提示词" → zpy-workflow create
```
优化提示词后，编排使用该提示词的工作流。

### Discover → Integrate → Use
```
zpy-discover "测试工具" → zpy-integrate plugin xxx → zpy-workflow run
```
发现工具 → 集成 → 纳入工作流。

### Full Pipeline (via zpy-flow)
```
zpy-flow think "新功能"
  → zpy-deepresearch "竞品分析"
  → zpy-agents 并行 [设计, 实现]
  → zpy-prompt optimize "测试提示词"
  → zpy-memory save "结论"
```

## Intermediate Data Passing

当链式调用时，中间产物按以下方式传递：

| Step | 输出 | 传递给下步 |
|------|------|-----------|
| discover | 工具列表/方案对比 | — 上下文传递 |
| deepresearch | 研究报告 | memory save 持久化 |
| agents | 实现代码/测试结果 | — 上下文传递 |
| workflow | 任务进度/产物 | session-state 持久化 |
| memory | 记忆条目 | — 跨会话 |
| prompt | 优化后的提示词 | — 上下文传递 |
