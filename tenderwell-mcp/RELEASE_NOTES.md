# Release Notes

## 0.2.0

### Added

- OAuth 2.1 sign-in guidance: the endpoint requires a signed-in Tenderwell user, and agents handle `401` responses by asking the user to reconnect instead of treating the server as unreachable.
- Pagination guidance for `searchTenders` and `searchOrganizations` using `page` and `pageSize`, including plan caps.
- Plan and usage limit guidance: access is coupled to the user's active plan, with daily search and read limits, `usage`, `notice`, and `paywall` handling.
- ChatGPT custom remote MCP setup instructions in the package README.

### Changed

- Agent instructions (`SKILL.md`, `CLAUDE.md`, `GEMINI.md`) were trimmed to rely on the MCP server's own tool schemas, which already define allowed filter fields and enum values.
- Access now follows the signed-in user's active plan instead of a default free plan.
- Removed development endpoint references; the only endpoint is `https://tenderwell.com/mcp`.

## 0.1.0 - Initial Release

Tenderwell MCP provides AI agent access to Tenderwell procurement intelligence through the Model Context Protocol.

### Added

- Codex plugin metadata for installing Tenderwell MCP from the Tenderwell marketplace.
- MCP server configuration for the hosted Tenderwell endpoint.
- Agent instructions for Codex, Claude, Claude Code, and Gemini CLI.
- Tender search and tender detail tools:
  - `searchTenders`
  - `readTender`
- Organization search and organization detail tools:
  - `searchOrganizations`
  - `readOrganization`
- Free-plan guidance for filtered or anonymized responses.
- Explicit rules for unsupported operations such as document downloads, saved searches, bookmarks, billing, account changes, and admin actions.

### Notes

- Default access uses the Tenderwell free plan.
- The hosted MCP endpoint is `https://tenderwell.com/mcp`.
- The MCP tools are read-only and do not modify Tenderwell data, user accounts, billing, or saved workspace state.
