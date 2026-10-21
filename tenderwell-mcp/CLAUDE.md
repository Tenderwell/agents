# Tenderwell MCP

Use the configured `tenderwell` MCP server when users ask about Tenderwell, government tenders, procurement opportunities, contracts, awards, buyers, suppliers, or organization lookup/search.

Primary MCP endpoint when available: `https://tenderwell.com/mcp`
Connectivity type: HTTP with streamable MCP transport
Access requires a signed-in Tenderwell user and follows that user's active Tenderwell plan. Treat returned data as already filtered or anonymized for that plan.

Tenderwell is a global procurement intelligence platform covering tenders, contracts, awards, buyers, suppliers, and organization insights.

## Scope

The MCP server supports searching tenders, reading a tender by ID, searching organizations, and reading an organization by ID. Do not claim support for document downloads, saved searches, bookmarks, pipeline actions, billing, account changes, or admin operations.

## Authentication

The endpoint requires sign-in with OAuth 2.1 (PKCE, dynamic client registration). The MCP client handles it: on a `401` with a `WWW-Authenticate` header it opens the Tenderwell sign-in page, where the user signs in or registers and approves access. No API key is needed, and the stored access token does not expire.

- If a call returns `401` or the Tenderwell tools report that authentication is required, tell the user to sign in or reconnect to Tenderwell from their client (for example `/mcp` in Claude Code, or `/mcp auth tenderwell` in Gemini CLI), then retry. Do not treat `401` as the server being unreachable.
- Never ask the user for a password, API key, or token, and do not try to obtain a token yourself.
- A revoked token returns `401` again and requires signing in again.

## Operating Rules

- Use the MCP tools as the source of truth for tender and organization data; do not scrape or infer records from the public website.
- If the request is unclear or required input is missing, ask for clarification before running tools.
- Search before reading when the user gives a description, keyword, buyer name, country, sector, or status instead of an ID. Summarize candidates with their IDs, then read details only for the relevant one.
- Do not invent tender or organization details, deadlines, budgets, countries, sectors, or source URLs.
- Preserve backend access control. Show all data returned, including anonymized fields; for values flagged `anonymized` or `paywall`, explain that the user's plan hides them and that upgrading unlocks them: [Tenderwell plans](https://tenderwell.com/plans).
- Relay any `notice`, `usage`, or tool error message from the server to the user instead of guessing plan limits. For limits beyond the user's plan, link to [Tenderwell plans](https://tenderwell.com/plans).
- Keep answers concise, cite returned tender or organization IDs, and format returned website or source URLs as Markdown links (never for missing, anonymized, or inferred URLs).
- When a response contains `anonymized` or `paywall` values or reports a reached limit, end it with a short note that upgrading at [Tenderwell plans](https://tenderwell.com/plans) shows fuller data.
- If the MCP server is unreachable (including `404`), say that the Tenderwell MCP server is not reachable and do not fall back to any other endpoint.
- When testing manually over HTTP, initialize once, keep the returned `Mcp-Session-Id`, send `Authorization: Bearer <token>` and `Accept: application/json, text/event-stream`, and handle `text/event-stream` responses.

## Plan and Usage Limits

The MCP is coupled to the user's active Tenderwell plan, so what a request may do depends on the plan and on daily usage.

- Each search and read counts against a daily limit. Responses include `usage` (`resource`, `used`, `limit`, `remaining`, `resetsAt`); a `limit` of `null` means unlimited. Do not spend calls needlessly (for example, do not read every search result), and mention remaining usage when it is low.
- Plans can restrict search: maximum `page` and `pageSize`, no custom filters, or default sorting only. A request outside these restrictions fails with an error describing what the plan allows. Adjust the request, or tell the user that upgrading removes the restriction.
- When the daily search limit is reached, searches still work with reduced access: a `notice` is returned and values marked `paywall: true` are hidden, and searches are restricted as described above until `resetsAt` or a plan upgrade.
- When the daily read limit is reached, reads fail with an error. Records already opened that day can still be read, but do not retry other records until the limit resets.

## Tool Payloads

Follow each tool's input schema; it lists the allowed fields and enum values.

- `searchTenders` and `searchOrganizations` take a top-level `filter` object. Send only the filters the request needs. Omit `null`, empty, `false`, and default values.
- Paginate with `page` (one-based, default `1`) and `pageSize` (default `10`) inside `filter`. Omit both for the first page. Search responses return `totalResults`, `page`, and `perPage`; to show more, request the next `page` with the same filters and sorting instead of raising `pageSize`.
- Plans may cap `page` and `pageSize`. If a request exceeds the cap, the error states the allowed maximums; retry within them.
- Use `sortOrder` only together with `sortBy`.
- Use CPV codes for `sectors`, `codeAlpha2` codes for countries, and `YYYY-MM-DD` for dates.
- `contractTypes` accepts only `WORKS`, `GOODS`, `SERVICES`, `CONSTRUCTION`, `COMBINED`, `OTHERS`, `CONSULTANCY_SERVICES`, or `UNKNOWN`.
- `organizationTypes` accepts only `CONTRACTING`, `BUYER`, or `AWARD`.
- `readTender` takes only `{"tenderId": ...}` and `readOrganization` only `{"organizationId": ...}`.
