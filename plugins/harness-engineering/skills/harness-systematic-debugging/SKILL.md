---
name: harness-systematic-debugging
description: Use when user says 修 bug, 调试, 报错, 不工作, 异常, debug, fix — ensures 4-phase systematic debugging, 3-failure rule, root cause analysis.
allowed-tools: Read, Bash, Grep, Glob, Edit
---

# Harness — Systematic Debugging Agent

<HARD-GATE>
修 bug 前必须：
1. 完整读取错误日志
2. 稳定复现步骤确认
3. 找到根因而非表象
4. 先写复现测试再修复
三次修复未成功 = 停止，讨论架构。
</HARD-GATE>

## 四阶段系统调试

### Phase 1: 根因调查
1. **完整读取错误日志**
   - 服务端日志
   - 客户端控制台
   - 网络请求详情

2. **稳定复现步骤**
   - 记录每次尝试的结果
   - 找出不变的条件

3. **检查最近 git 变更**
   - `git log --oneline -10`
   - `git diff` 查看改动
   - `git blame` 追溯责任代码

4. **打诊断日志**
   - 添加临时日志
   - 收集证据

### Phase 2: 模式分析
1. **找能跑通的类似代码**
   - 搜索项目中功能相似的代码
   - 对比差异点

2. **逐项对比差异**
   - 环境差异
   - 配置差异
   - 数据差异
   - 代码逻辑差异

### Phase 3: 单假设验证
1. **写下具体假设**
   - 不是"可能是这里"
   - 而是"因为 X 导致 Y"

2. **最小变更验证**
   - 只改一处
   - 不叠加多个改动

3. **三次失败规则**
   - 三次修复尝试未成功
   - 停止并讨论架构

### Phase 4: 实现修复
1. **先写复现测试**
   - 确保测试覆盖 bug 场景
   - Given/When/Then 结构

2. **只改一处**
   - 最小变更
   - 每次只验证一个假设

3. **验证修复**
   - 确认测试通过
   - 确认日志正常

4. **提交**
   - commit message 清晰描述根因
   - 关联相关 issue

---

## 三次失败规则

| 尝试次数 | 动作 |
|---------|------|
| 1 | 验证假设 A，修复 |
| 2 | 验证假设 B，修复 |
| 3 | 验证假设 C，修复 |
| 失败 | 停止修复，讨论架构问题 |

---

## 链式移交

| 下一 Skill | 触发条件 |
|-----------|----------|
| — | 修复完成或架构讨论 |