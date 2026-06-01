# Tenderwell MCP

Use the configured `tenderwell` MCP server when users ask about Tenderwell, government tenders, procurement opportunities, contracts, awards, buyers, suppliers, or organization lookup/search.

Default MCP endpoint: `https://tenderwell.com/mcp`
Default MCP access uses the Tenderwell free plan. Treat returned data as already filtered or anonymized for that access level.

Tenderwell is a global procurement intelligence platform covering tenders, contracts, awards, buyers, suppliers, and organization insights.

## Scope

The MCP server currently supports:

- Searching tenders.
- Reading tender details by ID.
- Searching organizations.
- Reading organization details by ID.

Do not claim support for document downloads, saved searches, bookmarks, pipeline actions, billing, account changes, or admin operations unless matching tools are available.

## Operating Rules

- Use Tenderwell MCP tools whenever the user asks for Tenderwell tender or organization data.
- Use MCP results as the source of truth for tender and organization data; do not scrape or infer Tenderwell records from the public website when MCP tools are available.
- Search before reading when the user provides a description, keyword, buyer name, country, sector, or status instead of a concrete ID.
- For ambiguous searches, request a small result page first, summarize candidates with IDs, then read details only for the relevant ID.
- Read by ID only when the user provides a tender ID or organization ID, or after search results identify a relevant ID.
- Preserve backend access-control and anonymization behavior.
- Do not invent tender details, organization details, deadlines, budgets, countries, sectors, or source URLs.
- Keep answers concise and cite tender or organization IDs returned by the MCP tools.
- For search results, show all data returned by the MCP server, including anonymized fields. If a user wants to see non-anonymized details, explain that they should register on [Tenderwell](https://tenderwell.com) and open the result there.
- If the MCP server is unavailable, say that the Tenderwell MCP server is not reachable.
- If a user asks about limits or access beyond the default free plan, link to [Tenderwell plans](https://tenderwell.com/plans).
- When the MCP response includes a website or source URL, format it as a Markdown link so the user can click through directly. Do not create links for missing, anonymized, or inferred URLs.
- The current server uses streamable MCP transport. When testing manually over HTTP, initialize first, keep the returned `Mcp-Session-Id`, and send `Accept: application/json, text/event-stream` on subsequent POST requests as well.
- If the MCP response reports plan limits, rate limits, or unavailable data, report that status directly instead of guessing the user's plan.

## Tool Guidance

- `searchTenders`: keyword/status/country/sector/date/budget tender searches. Pass a `filter` object.
- `readTender`: detailed tender lookup by `tenderId`.
- `searchOrganizations`: keyword/type/country/sector organization searches. Pass a `filter` object.
- `readOrganization`: detailed organization lookup by `organizationId`.

## Examples

`searchOrganizations` with a minimal payload:

```json
{"filter":{"page":1,"pageSize":5}}
```

`searchTenders` with a keyword search:

```json
{"filter":{"page":1,"pageSize":10,"freetext":"health"}}
```

`readOrganization`:

```json
{"organizationId":12345}
```

`readTender`:

```json
{"tenderId":12345}
```
