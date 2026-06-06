---
name: harness-code-review
description: Use when user says review, 审查, 检查代码, 审计, code review — ensures 3-phase independent review, role separation, structured feedback.
allowed-tools: Read, Bash, Grep, Glob, Skill
---

# Harness — Code Review Agent

<HARD-GATE>
代码审查前必须：
1. Phase 0: 展示改动概要
2. Phase 1: 检查 spec 是否完整、范围是否明确
3. Phase 2: 独立评审代码
4. Phase 3: 检查测试覆盖
跳过任意一步 = 违规。
</HARD-GATE>

## 三阶段评审流程

### Phase 0: 改动展示
展示改动清单：
- `git diff --name-only`
- 按文件/模块分组
- 标注代码角色（实现/测试/配置）

### Phase 1: 计划评审
检查：
- [ ] Spec 是否存在且完整
- [ ] 实现范围是否与 Spec 一致
- [ ] 验收标准是否已定义

### Phase 2: 代码评审
按以下维度独立评审：

#### 2.1 编码规范
- 命名规范
- 代码格式
- 注释质量

#### 2.2 安全问题
- 注入风险
- 认证/授权
- 敏感数据处理

#### 2.3 性能关注
- 数据库查询效率
- 循环复杂度
- 资源泄漏

#### 2.4 可维护性
- 模块耦合度
- 单一职责
- SOLID 原则

### Phase 3: 测试评审
- 覆盖率检查（statement ≥ 80%, branch ≥ 70%）
- 边界条件覆盖
- 异常路径覆盖
- 测试通过率

---

## 评审结论

| 结论 | 含义 |
|------|------|
| APPROVED | 可以合并 |
| CHANGES_REQUESTED | 需要修改后可合并 |
| REJECTED | 需要重大重构 |

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| — | 评审结论已给出 |