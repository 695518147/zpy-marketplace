# Settings Guide — zpy-plugin.local.md

zpy-plugin 支持通过 `.local.md` 文件进行用户自定义配置。

## 配置方式

在项目的 `.claude/` 目录下创建 `zpy-plugin.local.md`：

```bash
.claude/zpy-plugin.local.md
```

## 配置项

```yaml
---
# 记忆系统配置
memory:
  base_path: "~/.claude/memory"    # 记忆存储路径
  auto_compress_threshold: 70       # 自动压缩阈值（百分比）
  max_recall_results: 5             # 检索返回最大条数

# 研究默认配置
research:
  default_depth: "深入"             # 基础/深入/全面
  default_output: "report"          # report/markdown/html
  max_sub_agents: 4                 # 并行子 Agent 上限

# 工作流配置
workflow:
  default_retry: 1                  # 失败节点默认重试次数
  auto_persist: true                # 是否自动保存工作流状态

# Agent 配置
agent:
  default_model: "claude-sonnet-4-6" # 默认 Agent 模型
  timeout_minutes: 30               # Agent 超时时间
---
```

## 读取方式

在 skill 中通过 `Read .claude/zpy-plugin.local.md` 检查配置并解析 YAML frontmatter。

如果文件不存在，使用上述默认值。

## .gitignore

确保 `.gitignore` 中包含 `.claude/*.local.md`，避免将本地配置提交到仓库。
