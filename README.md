# Simple Injection plugin

A read-only plugin that lets an AI assistant (Claude, Codex / ChatGPT) look at your company's [Simple Injection](https://simpleinjection.com/) pumps and tank level monitors. It connects to the hosted Simple Injection dashboard MCP server over OAuth. From there it can list devices, show current device state, pull tank-level and battery history, and review alarms.

The plugin **cannot** operate equipment. It does not start or stop pumps, change setpoints, or handle purchases.

| | |
|---|---|
| Plugin ID | `simple-injection-dashboard` |
| Display name | Simple Injection |
| Version | 1.1.1 |
| MCP endpoint | `https://dashboard.simpleinjection.com/api/v1/mcp` (streamable HTTP) |
| Auth | OAuth 2.0 with PKCE, scope `devices:read` |
| Category | Business & Operations |

## Repository layout

This repository hosts the same plugin for two platforms. Each platform gets its own self-contained folder, so each is submitted and versioned independently.

```
.
├── .claude-plugin/marketplace.json            # Claude Code marketplace -> plugins/claude/...
├── .agents/plugins/marketplace.json           # Codex marketplace       -> plugins/openai/...
├── shared/                                    # Source of truth for files both plugins use
│   ├── assets/                                # icon.jpg (logo), icon.png (icon)
│   └── skills/simple-injection-operations/SKILL.md
├── plugins/
│   ├── claude/simple-injection-dashboard/     # Anthropic submission (plugin path)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                          # type "http" (Claude)
│   │   ├── README.md                          # Listing description; discloses what the plugin sends
│   │   └── assets/, skills/                   # Copies of shared/
│   └── openai/simple-injection-dashboard/     # OpenAI submission (zip this folder)
│       ├── plugin.json                        # Portable manifest + review test cases
│       ├── mcp.json                           # Portable MCP config (type "streamable-http")
│       ├── .codex-plugin/plugin.json          # Codex manifest -> ./.mcp.json
│       ├── .mcp.json
│       └── assets/, skills/                   # Copies of shared/
├── scripts/sync-shared.sh                     # Copies shared/ into each plugin folder
└── submission-notes/                          # Submission status, investigations, drafts
```

### Shared files

Plugin directories install only the plugin folder and reject symlinks, so shared files are committed as real copies. Edit them in `shared/`, then run:

```
scripts/sync-shared.sh           # update the copies
scripts/sync-shared.sh --check   # fail if any copy has drifted
```

Platform-specific files (manifests, MCP configs, the Claude README) live only in their plugin folder. Both MCP configs must keep the same server ID and URL; they differ only in `type`, because the portable schema requires `streamable-http` and the Claude directory requires `http`.

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

## Installation (Claude Code)

```
/plugin install simple-injection-dashboard --marketplace Simple-Injection/si-mcp-plugins
```

Then run `/mcp`, select `simple-injection-dashboard`, and complete the OAuth sign-in in the browser. Validate with `claude plugin validate --strict ./plugins/claude/simple-injection-dashboard --profile directory`. To submit, use plugin path `plugins/claude/simple-injection-dashboard` in the [developer portal](https://claude.ai/directory/manage).

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

- **Versions are independent per platform.** For an OpenAI release, bump `plugins/openai/simple-injection-dashboard/plugin.json` and `.codex-plugin/plugin.json` together and update `publication.release_notes`. For a Claude release, bump `plugins/claude/simple-injection-dashboard/.claude-plugin/plugin.json`; the directory requires a new version for every release.
- **Don't add server-level `extensions` to the MCP configs.** Codex Desktop rejects them (`unknown field extensions, expected url or headers`), which stops the server from loading before OAuth starts.
- **Keep the server ID as `simple-injection-dashboard`.** Existing user connections depend on it. Change only the display name.
- **Don't package credentials.** The server enforces OAuth and advertises it through its HTTP 401 challenge and OAuth metadata.
- **OpenAI review cases live in `plugins/openai/simple-injection-dashboard/plugin.json`.** They're under `extensions["com.openai"].review.test_cases` (5 positive, 3 negative). They use dated prompts, so update the dates and expectations before each review round.
- **`.zip` files are git-ignored.** Build a fresh archive of the contents of `plugins/openai/simple-injection-dashboard/` for each OpenAI upload. Older ZIPs (0.1.x) are out of date and shouldn't be used.

## Submission status

See [submission-notes/README.md](submission-notes/README.md) for current status, verification evidence, and remaining requirements: privacy addendum, running the review cases against live data, demo recording, and portal steps. Files under `submission-notes/history/` are older snapshots, not current configuration.

## Links

- Website: https://simpleinjection.com/
- Support: https://simpleinjection.com/contact
- Privacy policy: https://simpleinjection.com/privacy
- Terms of service: https://simpleinjection.com/terms
- OpenAI plugin docs: [packaging](https://developers.openai.com/plugins/build/plugins), [OAuth](https://developers.openai.com/plugins/build/auth)
