# Claude Connector Notes

Claude Code can use `configs/claude-code.mcp.json` or:

```bash
claude mcp add --transport http tenderwell https://tenderwell.com/mcp
```

Claude.ai connector or directory distribution is not controlled by `.codex-plugin/plugin.json`. Use the same remote MCP endpoint, tool descriptions, and operating rules from `CLAUDE.md` when preparing a Claude connector listing or submission.

Default endpoint:

```text
https://tenderwell.com/mcp
```

The endpoint requires Tenderwell sign-in (OAuth 2.1 with PKCE and dynamic client registration; no API key). Access follows the signed-in user's active Tenderwell plan, including its daily search and read limits.
