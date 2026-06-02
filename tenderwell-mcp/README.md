# Tenderwell MCP

Tenderwell MCP connects AI agent runtimes to Tenderwell procurement intelligence through MCP.

```text
https://tenderwell.com/mcp
```

Development endpoint:

```text
http://localhost:8088/mcp
```

Use `http://localhost:8088/mcp` for development. If the hosted endpoint is unavailable or returns `404`, try the development endpoint before treating the MCP server as unreachable.

## Overview

This package provides configuration and instruction files for:

- Codex
- Claude and Claude Code
- Gemini CLI

Default access uses the Tenderwell free plan. Responses may contain filtered or anonymized data. For non-anonymized details, users should register on [Tenderwell](https://tenderwell.com) and open the result there.

## Tools

The MCP server currently exposes:

| Tool | Purpose |
| --- | --- |
| `searchTenders` | Search tender opportunities, contracts, awards, and procurement notices. |
| `readTender` | Read tender details by `tenderId`. |
| `searchOrganizations` | Search buyers, suppliers, and other organizations. |
| `readOrganization` | Read organization details by `organizationId`. |

Unsupported operations include document downloads, saved searches, bookmarks, pipeline actions, billing, account changes, and admin operations unless future MCP tools expose them.

## Package Layout

```text
.agents/plugins/marketplace.json      Codex marketplace manifest
tenderwell-mcp/
  .codex-plugin/plugin.json          Codex plugin metadata
  .mcp.json                          Codex MCP server configuration
  scripts/tenderwell-mcp-health.sh   MCP initialize + tools/list preflight
  skills/tenderwell-mcp/SKILL.md     Codex skill instructions
  CLAUDE.md                          Claude / Claude Code instructions
  GEMINI.md                          Gemini CLI instructions
  configs/claude-code.mcp.json       Claude Code MCP configuration template
  configs/claude-connector.md        Claude connector notes
  configs/gemini.settings.json       Gemini CLI settings template
```

## Health Check

Run the preflight script before a full MCP workflow when you want a fast connectivity check:

```bash
./scripts/tenderwell-mcp-health.sh
```

By default it tries the hosted endpoint first and then the local development endpoint. You can also pass one or more endpoints explicitly:

```bash
./scripts/tenderwell-mcp-health.sh http://localhost:8088/mcp
```

The script verifies:

- `initialize` succeeds
- `tools/list` succeeds
- `tools/list` returns a non-empty tool list

Runtime instruction files treat this script as the preferred preflight step when MCP connectivity is uncertain, instead of doing manual `initialize` probing first.

## Codex

Codex installs plugins from configured marketplaces. This repository includes a marketplace manifest at `.agents/plugins/marketplace.json`, so install Codex support in two steps:

1. Register the repository as a Codex marketplace.
2. Install `tenderwell-mcp` from the `tenderwell` marketplace.

```bash
codex plugin marketplace add https://github.com/Tenderwell/agents
codex plugin marketplace list // Check if Tenderwell is present as marketplace
codex plugin add tenderwell-mcp@tenderwell
```

To upgrade the marketplace:

```bash
codex plugin marketplace upgrade tenderwell
```

## Claude Code

Add the Tenderwell MCP server with the Claude Code CLI for development:

```bash
claude mcp add --transport http tenderwell http://localhost:8088/mcp
```

Alternatively, copy the project-level MCP template:

```bash
cp configs/claude-code.mcp.json .mcp.json
```

Place `CLAUDE.md` in the Claude Code project where the Tenderwell instructions should apply.

For Claude connector or directory packaging, start from `configs/claude-connector.md`.

## Gemini CLI

Add the Tenderwell MCP server with the Gemini CLI for development:

```bash
gemini mcp add --transport http tenderwell http://localhost:8088/mcp
```

Alternatively, merge `configs/gemini.settings.json` into one of:

- `~/.gemini/settings.json`
- `.gemini/settings.json`

Place `GEMINI.md` in the Gemini CLI project where the Tenderwell instructions should apply.

## Agent Instructions

Runtime-specific instruction files should stay aligned:

- `skills/tenderwell-mcp/SKILL.md`
- `CLAUDE.md`
- `GEMINI.md`

These files define when to use Tenderwell MCP, how to handle anonymized data, when to search before reading by ID, and which operations are unsupported.

## Notes

There is no universal plugin manifest shared by Codex, Claude, and Gemini. MCP is the common integration layer; each runtime has its own configuration and instruction format.
