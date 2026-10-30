# Simple Injection

A read-only plugin that lets Claude look at your company's [Simple Injection](https://simpleinjection.com/) pumps and tank level monitors. It can list devices with their latest readings, show the current state of a device, pull tank-level and battery history, and review active alarms and alarm history.

The plugin **cannot** operate equipment. It does not start or stop pumps, change setpoints, or handle purchases.

## What it connects to and sends

- **One remote MCP server:** `https://dashboard.simpleinjection.com/api/v1/mcp` (HTTP), run by Simple Injection. The plugin runs no local commands, hooks, or scripts.
- **Authentication:** OAuth 2.0 with PKCE and the `devices:read` scope. You sign in on the Simple Injection dashboard in your browser. The plugin contains no credentials and never asks for them in chat.
- **Data sent:** the tool arguments Claude chooses: a device IMEI, a start date, and a result limit.
- **Data returned:** device identifiers and names, head status, setpoints, tank levels, battery voltage, reading history, alarm messages with timestamps, and, through `get_profile`, the connected account's name, email, and company label. Results are limited to the company you signed in with.

## Tools

| Tool | Purpose |
|---|---|
| `list_devices` | Pumps and tank level monitors with their latest readings |
| `get_device` | Current state of one device |
| `get_device_history` | Tank-level and battery readings since a date (up to 365 days back) |
| `get_device_alarms` | Active alarms and alarm history |
| `get_profile` | The connected account and company |

## Setup

```
/plugin install simple-injection-dashboard --marketplace Simple-Injection/si-mcp-plugins
```

After installing, run `/mcp`, select `simple-injection-dashboard`, and complete the sign-in in your browser. Then ask, for example: "List my company's pumps and tank level monitors."

## Links

- Privacy policy: https://simpleinjection.com/privacy
- Terms of service: https://simpleinjection.com/terms
- Support: https://simpleinjection.com/contact

Licensed under Apache-2.0.
