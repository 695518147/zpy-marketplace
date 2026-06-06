---
name: zpy-integrate
description: This skill should be used when the user asks to "集成", "integrate", "导入技能", "import", "安装插件", "merge config", "添加仓库", "合并设置", "bring in", "集成外部", or wants to import external repositories, skills, plugins, or documentation into the current workflow.
argument-hint: "[源类型: repo/skill/plugin/doc/mcp] [源地址或名称] [可选参数]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - WebFetch
---

# zpy-integrate

Import external repositories, skills, plugins, documentation, and MCP services into the current Claude Code project environment.

## Integration types

### repo — import a repository

Procedure:
1. Clone the repo (or link if local path given)
2. Analyze directory structure, look for skills/, commands/, agents/
3. Read CLAUDE.md or similar context files
4. Present integration report: what was found and what can be imported
5. Ask user which components to integrate

```
/zpy-plugin:integrate repo https://github.com/user/repo
/zpy-plugin:integrate repo ~/github/my-project
```

### skill — import a skill

Procedure:
1. Locate the skill's SKILL.md
2. Check for naming conflicts with existing skills
3. Copy to `.claude/skills/<new-name>/SKILL.md` if standalone
4. Register if needed
5. Report new skill availability

```
/zpy-plugin:integrate skill other-plugin:skill-name
/zpy-plugin:integrate skill ~/github/project/skills/custom-skill
```

### plugin — install from marketplace

Procedure:
1. Check if plugin is already installed
2. If not, use `/plugin install <name>` or copy to `.claude/plugins/`
3. Smart-merge settings (append new hooks, don't overwrite existing)
4. Verify no critical conflicts with installed plugins

```
/zpy-plugin:integrate plugin wshobson/agents
```

### doc — import best practices

Procedure:
1. Read the document content
2. Extract actionable rules, constraints, and conventions
3. Present merge diff to the user
4. On approval, append relevant sections to CLAUDE.md or create a rules file

```
/zpy-plugin:integrate doc best-practices.md
/zpy-plugin:integrate doc https://example.com/style-guide
```

### mcp — add MCP server

Procedure:
1. Install the MCP server (npm/pip/brew as needed)
2. Read its documentation for required env vars
3. Add to `.mcp.json` or `.claude/settings.json` MCP config
4. Verify connection

```
/zpy-plugin:integrate mcp @modelcontextprotocol/server-filesystem
```

## Smart merge rules

For config file merging:
- `settings.json` / `settings.local.json`: append new hooks, keep existing hooks intact
- `CLAUDE.md`: selectively merge rule sections; ask before overwriting project-specific content
- `.mcp.json`: add new server entries; keep existing servers
- `hooks.json`: merge hook arrays; detect and flag duplicates

## Related skills

- **`zpy-discover`** — use before integrate to find what's available
- **`zpy-flow`** — use after integrate to route newly integrated capabilities
