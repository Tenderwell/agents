# Tenderwell Agents

This repository is a monorepo for Tenderwell agent integrations.

Each top-level directory contains one integration package with the files needed by one or more AI agent runtimes. The shared goal is to expose Tenderwell procurement intelligence through MCP and runtime-specific instruction files.

## Packages

### `tenderwell-mcp`

Tenderwell MCP integration for searching and reading tenders and organizations.

Supported targets:

- Codex: plugin manifest, MCP config, and Codex skill.
- Claude and Claude Code: MCP config and `CLAUDE.md` instructions.
- Gemini CLI: MCP config and `GEMINI.md` instructions.

Default MCP endpoint:

```text
https://tenderwell.com/mcp
```

See [`tenderwell-mcp/README.md`](tenderwell-mcp/README.md) for installation and runtime-specific setup.
