# Simple Injection plugin

A read-only plugin that lets an AI assistant (Codex / ChatGPT plugins) look at your company's [Simple Injection](https://simpleinjection.com/) pumps and tank level monitors. It connects to the hosted Simple Injection dashboard MCP server over OAuth. From there it can list devices, show current device state, pull tank-level and battery history, and review alarms.

The plugin **cannot** operate equipment. It does not start or stop pumps, change setpoints, or handle purchases.

| | |
|---|---|
| Plugin ID | `simple-injection-dashboard` |
| Display name | Simple Injection |
| Version | 0.1.6 |
| MCP endpoint | `https://dashboard.simpleinjection.com/api/v1/mcp` (streamable HTTP) |
| Auth | OAuth 2.0 with PKCE, scope `devices:read` |
| Category | Business & Operations |

## Repository layout

```
.
├── .agents/plugins/marketplace.json   # Local marketplace "simple-injection-plugins"
├── simple-injection/                  # Plugin source (this is what gets installed/packaged)
│   ├── .codex-plugin/plugin.json      # Codex manifest -> ./.mcp.json
│   ├── .mcp.json                      # MCP server config used by the Codex manifest
│   ├── plugin.json                    # Portable manifest (agent-plugins schema) + review test cases
│   ├── mcp.json                       # MCP server config discovered by portable clients
│   ├── assets/                        # icon.jpg (logo), icon.png (composer icon)
│   └── skills/simple-injection-operations/SKILL.md   # Agent instructions for using the tools
└── submission-notes/                  # Plugin directory submission status, investigations, drafts
```

The two manifests and the two MCP config files are meant to stay in sync: same version, same server ID, same URL.

## Tools

The MCP server provides these tools. They are all read-only.

| Tool | Purpose | Arguments |
|---|---|---|
| `list_devices` | Lists the company's pumps (`devices`) and tank level monitors (`tank_level_monitors`), with their latest readings | none |
| `get_device` | Gets the current state of one device: head status, setpoints, tank levels, battery voltage | `device_imei` |
| `get_device_history` | Gets tank-level and battery readings over time, downsampled when there are too many | `device_imei`, `start_date` (`YYYY-MM-DD`), `max_points` (2–1000, default 200) |
| `get_device_alarms` | Gets active alarms and alarm history | `device_imei`, `since_date` (`YYYY-MM-DD`), `limit` (1–500) |
| `get_profile` | Gets the connected account and company labels (OAuth connections only, and only on newer server deployments) | none |

History and alarm queries can look back at most 365 days. Every result is limited to the company that authenticated.

## Installation (local, Codex CLI)

Run these from the repository root:

```powershell
codex plugin marketplace add .
codex plugin add simple-injection-dashboard@simple-injection-plugins
codex mcp login simple-injection-dashboard --scopes devices:read
```

Finish sign-in and consent in the browser. Never type credentials into chat. Then start a new chat so the tools load, select **Simple Injection**, and run the starter prompt:

> Connect to Simple Injection and list my company's pumps and tank level monitors.

To check connection status:

```powershell
codex mcp list --json
```

A healthy connection reports `authStatus: oAuth` and lists the four device tools.

## Example prompts

- "List my company's pumps and tank level monitors, with the latest tank readings and update times."
- "For the pump with the smallest IMEI, show its current head status, setpoints, tank levels and battery voltage."
- "Show tank level and battery history since October 7, 2026 for that pump."
- "Show active alarms and the five most recent alarm-history entries since October 7, 2026."
- "Which Simple Injection account is connected?" (uses `get_profile`)

The plugin will turn down requests like "stop every pump" or "buy a new pump". It also won't try to reach another company's data.

## Development notes

- **Bump the version in both manifests.** Update `simple-injection/plugin.json` and `simple-injection/.codex-plugin/plugin.json` together. Also update `publication.release_notes` in `plugin.json`.
- **Don't add server-level `extensions` to the MCP configs.** Codex Desktop rejects them (`unknown field extensions, expected url or headers`), which stops the server from loading before OAuth starts.
- **Keep the server ID as `simple-injection-dashboard`.** Existing user connections depend on it. Change only the display name.
- **Don't package credentials.** The server enforces OAuth and advertises it through its HTTP 401 challenge and OAuth metadata.
- **Review cases live in `plugin.json`.** They're under `extensions["com.openai"].review.test_cases` (5 positive, 3 negative). They use dated prompts, so update the dates and expectations before each review round.
- **`.zip` files are git-ignored.** Build a fresh archive of `simple-injection/` for each upload. Older 0.1.3/0.1.4 ZIPs are out of date and shouldn't be used.

## Submission status

See [submission-notes/README.md](submission-notes/README.md) for current status, verification evidence, and remaining requirements: privacy addendum, running the review cases against live data, demo recording, and portal steps. Files under `submission-notes/history/` are older snapshots, not current configuration.

## Links

- Website: https://simpleinjection.com/
- Support: https://simpleinjection.com/contact
- Privacy policy: https://simpleinjection.com/privacy
- Terms of service: https://simpleinjection.com/terms
- OpenAI plugin docs: [packaging](https://developers.openai.com/plugins/build/plugins), [OAuth](https://developers.openai.com/plugins/build/auth)
