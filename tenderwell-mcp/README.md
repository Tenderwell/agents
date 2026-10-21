# Tenderwell MCP

Tenderwell MCP connects AI agent runtimes to Tenderwell procurement intelligence through MCP.

```text
https://tenderwell.com/mcp
```

## Overview

This package provides configuration and instruction files for:

- Codex (marketplace plugin or direct MCP connection)
- ChatGPT (custom remote MCP connection through Plugins)
- Claude and Claude Code
- Gemini CLI

Access requires a Tenderwell account, which is free to create. The MCP is coupled to the signed-in user's active Tenderwell plan: the plan decides which data is returned in full, which search options are allowed, and how many searches and reads are allowed per day. See [Plans and usage limits](#plans-and-usage-limits). For fuller details or higher limits, see [Tenderwell plans](https://tenderwell.com/plans).

## Authentication

The Tenderwell MCP endpoint requires sign-in. Calls without a valid token return `401` with a `WWW-Authenticate` header, and MCP clients that support OAuth start the sign-in flow automatically:

1. The client opens the browser on the Tenderwell sign-in page.
2. The user signs in or registers, then approves the connection.
3. The browser returns to the client, which stores the access token and sends it with every request. CLI clients (Claude Code, Gemini CLI, Codex CLI) keep the token on your device; ChatGPT and the Claude apps connect from their providers' cloud services, which hold the token.

No API key needs to be copied. The flow uses OAuth 2.1 with PKCE and dynamic client registration, so the MCP configuration only needs the endpoint URL.

Start the sign-in from the client:

| Client | How to sign in |
| --- | --- |
| Claude app | Select Connect on the Tenderwell connector, then sign in to Tenderwell and approve access. |
| Claude Code | Run `/mcp`, select `tenderwell`, and choose Authenticate. Newer versions also support `claude mcp login tenderwell`. |
| Gemini CLI | Run `/mcp auth tenderwell`. |
| Codex CLI, direct MCP connection | Run `codex mcp login tenderwell`. |
| Codex app, direct MCP connection | Save and restart, then select Authenticate for the server when required. |
| Codex marketplace plugin | Follow the installed plugin’s connection and sign-in prompts. |
| ChatGPT | Install the custom plugin and connect it when prompted, then sign in to Tenderwell and approve access. |

The access token does not expire. If it is revoked, the next request returns `401` and the client prompts for sign-in again.

Tools cannot be called manually with `curl` unless the request carries an `Authorization: Bearer` token obtained through this flow.

## Tools

The MCP server currently exposes:

| Tool | Purpose |
| --- | --- |
| `searchTenders` | Search tender opportunities, contracts, awards, and procurement notices. |
| `readTender` | Read tender details by `tenderId`. |
| `searchOrganizations` | Search buyers, suppliers, and other organizations. |
| `readOrganization` | Read organization details by `organizationId`. |

Unsupported operations include document downloads, saved searches, bookmarks, pipeline actions, billing, account changes, and admin operations unless future MCP tools expose them.

### Pagination

`searchTenders` and `searchOrganizations` accept `page` (one-based, default `1`) and `pageSize` (default `10`) inside the `filter` object. Responses include `totalResults`, `page`, and `perPage`, so an agent can request the next `page` with the same filters and sorting to see more results. Plans may cap the maximum `page` and `pageSize`; a request above the cap returns an error stating the allowed maximums.

## Plans and usage limits

Every call runs under the signed-in user's active Tenderwell plan, and restrictions depend on that plan and on daily usage:

- **Daily usage limits.** Searches and reads count against per-resource daily limits. Each response includes a `usage` object with `resource`, `used`, `limit` (`null` when unlimited), `remaining`, and `resetsAt` (when the daily counter resets).
- **Search restrictions.** A plan can cap `page` and `pageSize`, disallow custom filters, or allow only the default sorting. A request outside the plan returns an error that describes what is allowed.
- **Search limit reached.** Searches keep working with reduced access. The response carries a `notice`, values marked `paywall: true` are hidden, and the restrictions above apply until the counter resets or the plan is upgraded.
- **Read limit reached.** Reads return an error that links to the upgrade page. Records already opened that day can still be read.
- **Anonymized data.** Fields flagged `anonymized` are hidden by the plan's access rules; the user can upgrade their plan on [Tenderwell](https://tenderwell.com/plans) to see them.

Agents should relay `notice`, `usage`, and error messages to the user rather than guessing limits.

## Package Layout

```text
.agents/plugins/marketplace.json      Codex marketplace manifest
tenderwell-mcp/
  .codex-plugin/plugin.json          Codex plugin metadata
  .mcp.json                          Codex MCP server configuration
  skills/tenderwell-mcp/SKILL.md     Codex skill instructions
  CLAUDE.md                          Claude / Claude Code instructions
  GEMINI.md                          Gemini CLI instructions
  RELEASE_NOTES.md                   Package release notes
  configs/claude-code.mcp.json       Claude Code MCP configuration template
  configs/claude-connector.md        Claude connector notes
  configs/gemini.settings.json       Gemini CLI settings template
```

Normal operation should use the direct MCP flow instead: initialize once, keep the returned `Mcp-Session-Id`, then call the requested tool with `Accept: application/json, text/event-stream`.

## Choose your setup

- **App users:** follow the Codex app or ChatGPT steps below. No terminal or API key is needed for these direct MCP connections.
- **Developers:** install the Codex marketplace plugin to get both the tools and the packaged Tenderwell skill. A direct MCP connection is also available when you only need the tools.

The marketplace is named `tenderwell`; the plugin is named `tenderwell-mcp`; its bundled MCP server is named `tenderwell`. Choose either the Codex plugin or a direct MCP connection in the same client to avoid duplicate tools.

A repository marketplace is separate from the public ChatGPT/Codex plugin directory. This repository does not establish a public directory listing or a one-click install link. Local Codex configuration is not imported by ChatGPT on the web; use the ChatGPT steps below for a custom connection. Account and workspace policies may limit which plugins or custom MCP servers a user can add.

## Codex app: direct MCP connection

1. Open Codex and go to **Settings → MCP servers**.
2. Select **Add server**, then choose **Streamable HTTP**.
3. Enter `tenderwell` as the server name and `https://tenderwell.com/mcp` as the URL. No API key is needed.
4. Save, then select **Restart**. If sign-in is required, select **Authenticate**, sign in to Tenderwell and approve access.
5. Start a new chat and ask Codex to use Tenderwell to find tenders. Use `/mcp` to view connected servers.

This connects the MCP tools without installing `skills/tenderwell-mcp/SKILL.md`. For the complete plugin, follow the marketplace steps below.

## ChatGPT: connect through Plugins

1. Open **ChatGPT → Plugins**, select the plus button, then **Add custom MCP server**. If this option is missing, check your account’s available features or contact your workspace admin.
2. Enter `Tenderwell` as the name, add a short description such as “Search tenders and organizations”, and use `https://tenderwell.com/mcp` as the server URL.
3. Select **OAuth** for authentication. No API key is needed.
4. Review the connection details and risk warning, confirm that you want to continue, then select **Create as a plugin**. Review the discovered tools.
5. Install the resulting plugin and connect it when prompted. Sign in to Tenderwell and approve access.
6. Start a new chat, type `@` and select your Tenderwell plugin. Ask it to find tenders.

This custom connection provides the remote MCP tools. It does not install the Tenderwell skill packaged in this repository. Registering the repository as a Codex marketplace does not automatically install this custom ChatGPT connection.

## Codex CLI: marketplace plugin

With Codex CLI installed, register the repository as a marketplace:

```bash
codex plugin marketplace add https://github.com/Tenderwell/agents
```

Start Codex:

```bash
codex
```

Inside Codex, open the plugin browser:

```text
/plugins
```

Choose the `tenderwell` marketplace, select `tenderwell-mcp` and install it. Follow any connection and Tenderwell sign-in prompts and approve access. Start a new Codex session after installation so its bundled skill and tools become available.

This installs both the MCP connection and the Tenderwell usage instructions from `skills/tenderwell-mcp/SKILL.md`. The plugin browser avoids relying on a version-specific `codex plugin add` command.

To inspect registered marketplaces or refresh the Tenderwell marketplace:

```bash
codex plugin marketplace list
codex plugin marketplace upgrade tenderwell
```

After upgrading, reopen the plugin browser, apply any available plugin update and start a new session.

## Codex CLI: direct MCP connection

Alternatively, with Codex CLI installed, register only the MCP server:

```bash
codex mcp add tenderwell --url https://tenderwell.com/mcp
codex mcp login tenderwell
```

Complete sign-in and consent in your browser, then start a new Codex session. Use `/mcp` inside Codex to check the connection. This option does not install the Tenderwell skill.

## Try the connection

Ask your assistant:

> Use Tenderwell to find open road construction tenders in Kenya with a deadline this month.

If the assistant does not use Tenderwell, select the plugin with `@` in ChatGPT or check `/mcp` in Codex and start a new chat/session. If sign-in fails or access is revoked, reconnect from the client and approve access again. If the custom-server option is unavailable, check account and workspace permissions. Filtered results, pagination caps, and daily usage limits follow the connected user’s Tenderwell plan (see [Plans and usage limits](#plans-and-usage-limits)).

The tools available through either setup are listed above. Downloads, saved searches, bookmarks, billing and account changes are not supported by this integration.

### Official setup references

- [ChatGPT and Codex plugin installation](https://learn.chatgpt.com/docs/plugins)
- [Codex MCP configuration and OAuth](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
- [Connect a custom MCP server in ChatGPT](https://developers.openai.com/plugins/deploy/connect-chatgpt)
- [Plugin packaging and marketplace registration](https://developers.openai.com/plugins/build/plugins)

## Claude app: custom connector

**Individual (Pro and Max) plans:**

1. Open Claude on the web (claude.ai) or the desktop app and go to **Customize → Connectors**.
2. Select **+ Add**, then **Add custom connector**.
3. Enter `Tenderwell` as the name and `https://tenderwell.com/mcp` as the URL, then select **Continue**. No API key is needed.
4. Review the detected authentication settings and select **Continue**. Tenderwell supports dynamic client registration, so keep the recommended OAuth client option (**Use Claude's published identity**) or choose **Register automatically**.
5. Select **Add**, then **Connect**. Sign in to Tenderwell and approve access.
6. Start a new chat, enable the Tenderwell connector from the **+** menu and ask Claude to find tenders.

**Team and Enterprise plans:** an organization owner first adds the connector under **Organization settings → Connectors** (**Add → Custom → Web**) with the same name and URL and the same authentication settings. Members then open **Customize → Connectors**, find Tenderwell and select **Connect**.

Claude connects to the server from Anthropic's cloud infrastructure, not from your device. Account and workspace policies may limit which custom connectors a user can add.

## Claude Code: terminal

With Claude Code installed, add the Tenderwell MCP server:

```bash
claude mcp add --scope user --transport http tenderwell https://tenderwell.com/mcp
```

Start Claude Code, run `/mcp`, select `tenderwell` and choose **Authenticate**. Sign in to Tenderwell and approve access in your browser, then start a new session. Newer versions also support `claude mcp login tenderwell`.

## Gemini CLI

With Gemini CLI installed, add the Tenderwell MCP server:

```bash
gemini mcp add --transport http tenderwell https://tenderwell.com/mcp
```

Alternatively, merge `configs/gemini.settings.json` into `~/.gemini/settings.json` (all projects) or `.gemini/settings.json` (one project). Start Gemini CLI, run `/mcp auth tenderwell`, then sign in to Tenderwell and approve access in your browser.

Place `GEMINI.md` in the Gemini CLI project where the Tenderwell instructions should apply.

## Agent Instructions

Runtime-specific instruction files should stay aligned:

- `skills/tenderwell-mcp/SKILL.md`
- `CLAUDE.md`
- `GEMINI.md`

These files define when to use Tenderwell MCP, how to handle anonymized data and plan or usage limits, how to paginate, when to search before reading by ID, and which operations are unsupported.

## Notes

There is no universal plugin manifest shared by Codex, Claude, and Gemini. MCP is the common integration layer; each runtime has its own configuration and instruction format.
