# Application Owner Agent — 10阶段流水线 + 5质量门禁 + 角色分离

本文档定义 Harness Engineering 的核心流水线，由 harness-entry 加载并供所有 Skill 引用。

---

## 10 阶段流水线

### Stage 0: 会话启动
- **执行者**: harness-entry
- **产物**: 纪律基线、能力声明、知识索引加载
- **门禁**: 无

### Stage 1: 需求澄清
- **执行者**: harness-brainstorming
- **产物**: 澄清问题列表、方案选项
- **门禁**: G1. 所有关键问题已澄清

### Stage 2: 设计评审
- **执行者**: harness-brainstorming
- **产物**: Committed Spec 文件
- **门禁**: G2. 用户已 approved Spec

### Stage 3: 实现开发
- **执行者**: harness-implementation
- **产物**: 实现代码、测试文件
- **门禁**: G3. Spec 已 approved

### Stage 4: 单元测试
- **执行者**: harness-testing (Path A)
- **产物**: 通过的测试 + 覆盖率报告
- **门禁**: G4. statement ≥ 80%, branch ≥ 70%

### Stage 5: E2E 测试
- **执行者**: harness-testing (Path B)
- **产物**: 截图 + 测试报告
- **门禁**: G5. 关键路径通过

### Stage 6: 性能压测
- **执行者**: harness-testing (Path C)
- **产物**: 压测报告 + 动态门禁判定
- **门禁**: G5. 性能指标达标

### Stage 7: 代码评审
- **执行者**: harness-code-review
- **产物**: 评审结论
- **门禁**: G5. APPROVED 结论

### Stage 8: 提交代码
- **执行者**: finishing skill
- **产物**: commit / PR
- **门禁**: G5. 评审通过

### Stage 9: 文档交付
- **执行者**: harness-document-generation
- **产物**: .md + .docx
- **门禁**: G1. 用户已审阅

---

## 5 个质量门禁

| 门禁 | 名称 | 判定条件 |
|------|------|----------|
| G1 | 需求澄清门禁 | 所有关键问题已澄清 |
| G2 | 设计评审门禁 | Spec 已 approved |
| G3 | 实现准入门禁 | Spec 已 approved |
| G4 | 测试通过门禁 | 覆盖率达到标 |
| G5 | 质量评审门禁 | 代码评审 APPROVED |

---

## 角色分离

| 角色 | 职责 | 进入阶段 |
|------|------|----------|
| PM/产品经理 | 需求澄清、设计文档 | Stage 1 |
| 架构师/Tech Lead | 系统方案设计 | Stage 2 |
| 前端/后端开发 | 实现开发 | Stage 3 |
| 测试工程师 | 测试执行 | Stage 4-6 |
| Reviewer | 代码评审 | Stage 7 |

---

## 流水线状态文件

每个阶段完成后写入 `pipeline-state.json`，下游角色通过读取该文件自动确定接续点：

```json
{
  "current_stage": 3,
  "stage_1_completed": true,
  "stage_2_approved": true,
  "spec_path": "spec/2026-05-28-user-system-design.md",
  "artifacts": {
    "stage_3": ["src/UserService.java", "src/UserController.java"]
  }
}
```