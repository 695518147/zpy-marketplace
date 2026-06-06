# Pipeline State Schema — 流水线状态文件 Schema

本文档定义 `pipeline-state.json` 的结构和语义。

---

## Schema

```json
{
  "current_stage": 0,
  "stage_0_completed": true,
  "stage_1_completed": false,
  "stage_2_approved": false,
  "spec_path": null,
  "artifacts": {
    "stage_0": [],
    "stage_1": [],
    "stage_2": [],
    "stage_3": [],
    "stage_4": [],
    "stage_5": [],
    "stage_6": [],
    "stage_7": [],
    "stage_8": [],
    "stage_9": []
  },
  "metadata": {
    "created_at": "2026-05-28T00:00:00Z",
    "updated_at": "2026-05-28T00:00:00Z",
    "user_confirmed": false
  }
}
```

---

## Stage 定义

| Stage | 名称 | Skill |
|-------|------|-------|
| 0 | 会话启动 | harness-entry |
| 1 | 需求澄清 | harness-brainstorming |
| 2 | 设计评审 | harness-brainstorming |
| 3 | 实现开发 | harness-implementation |
| 4 | 单元测试 | harness-testing |
| 5 | E2E 测试 | harness-testing |
| 6 | 性能压测 | harness-testing |
| 7 | 代码评审 | harness-code-review |
| 8 | 提交代码 | finishing |
| 9 | 文档交付 | harness-document-generation |

---

## 门禁状态

| 门禁 | 名称 | 字段 |
|------|------|------|
| G1 | 需求澄清门禁 | stage_1_completed |
| G2 | 设计评审门禁 | stage_2_approved |
| G3 | 实现准入门禁 | stage_2_approved |
| G4 | 测试通过门禁 | stage_4_completed |
| G5 | 质量评审门禁 | stage_7_approved |