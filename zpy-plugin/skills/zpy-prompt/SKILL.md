---
name: zpy-prompt
description: This skill should be used when the user asks to "优化提示词", "prompt optimize", "提示词优化", "改进 prompt", "评估提示词", "A/B test prompt", "模板管理", "提示词模板", "improve this prompt", or wants to analyze and enhance the quality of an AI prompt.
argument-hint: "[操作: optimize/evaluate/compare/template/test] [提示词内容或模板名]"
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - Agent
---

# zpy-prompt

Analyze, optimize, evaluate, and manage AI prompts. Based on Prompt Optimizer (linshenkx/prompt-optimizer) methodology.

## Operations

### optimize — enhance a prompt

Given a prompt draft, apply these optimizations:

1. **Structure analysis**: Check for presence of Goal, Context, Constraints, Output Format, Examples
2. **Clarity pass**: Remove ambiguity, vague references, and filler words
3. **Constraint hardening**: Make implicit constraints explicit (format, length, tone, audience)
4. **Example injection**: Add relevant examples where they improve output quality
5. **Output**: Present the optimized prompt with a changelog of what was changed and why

Support two modes:
- **System prompt mode**: Optimize role definition, behavior constraints, output rules
- **User prompt mode**: Optimize input clarity, specificity, actionability

### evaluate — score a prompt

Assess against these dimensions (1–10 scale):
- **Clarity**: How unambiguous is the instruction?
- **Completeness**: Are all necessary elements present?
- **Specificity**: Are constraints and output format detailed enough?
- **Efficiency**: Is there redundant or unnecessary content?
- **Actionability**: Can an AI execute this without clarification?

Output a radar chart (text-based) and improvement suggestions.

### compare — A/B test two prompts

Run both prompts against the same task, present side-by-side comparison:

```
Dimension      | Version A | Version B
Clarity        | 7         | 9
Completeness   | 8         | 7
Specificity    | 6         | 9
Recommendation | —         | ✓ Winner
```

Use Agent to evaluate each version independently.

### template — manage prompt templates

List, load, or create reusable templates:
- `template list` — show all available templates
- `template load <name>` — load a template for editing
- `template save <name>` — save current prompt as template
- Support variables: `{{variable_name}}` for parameterization

Built-in template categories:
- Code generation, API design, Code review, Documentation, Analysis, Creative writing

### test — run multi-turn tests

For user prompts with variables:
1. Define variable sets
2. Run each combination against the prompt
3. Collect and compare results
4. Report which variable configuration produced the best output

## Output quality framework

After optimization, always present:
1. **Before/After diff** — what changed
2. **Optimization rationale** — why each change was made
3. **Suggested usage** — when and how to use this prompt
