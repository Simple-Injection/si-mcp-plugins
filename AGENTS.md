# Agent instructions

## This repository is public

Everything committed here, including history, commit messages, tags, and release notes, is publicly visible. Never write sensitive information to tracked files or GitHub metadata:

- credentials, passwords, API keys, tokens, OAuth client secrets, or cookies
- reviewer or demo account logins, and instructions for accessing them
- internal platform IDs (for example OpenAI plugin or release IDs), private portal links, or customer data
- personal contact details beyond the public support and privacy addresses already in the manifests

Keep submission notes, reviewer access details, and drafts in `submission-notes/`. It is git-ignored and exists only on the maintainer's machine. Enter reviewer credentials only in the submission portals' secure fields. If sensitive data is ever committed, stop and tell the user: removing it from `HEAD` does not remove it from history.

## Layout

The repo hosts one plugin for two platforms. Each platform has its own self-contained folder, submitted and versioned independently:

- `plugins/claude/simple-injection-dashboard/`: Anthropic directory submission
- `plugins/openai/simple-injection-dashboard/`: OpenAI submission (uploaded as a zip of this folder)
- `shared/`: source of truth for the skill and assets. Edit files here, then run `scripts/sync-shared.sh`. Never edit the copies in `plugins/*/` directly, and never use symlinks. `scripts/sync-shared.sh --check` must pass before committing.

Keep the plugin `name` and MCP server ID `simple-injection-dashboard` unchanged on both platforms; existing connections depend on them. Skill `name` fields must be lowercase hyphenated IDs. The OpenAI display name goes in the skill's `agents/openai.yaml`.

## Releases

Every version change must ship as a Git tag and a GitHub release. Each platform is tagged separately:

| Platform | Version files | Tag |
|---|---|---|
| Claude | `plugins/claude/simple-injection-dashboard/.claude-plugin/plugin.json` | `claude-v<version>` |
| OpenAI | `plugins/openai/simple-injection-dashboard/plugin.json` and `.codex-plugin/plugin.json` (keep equal), plus `publication.release_notes` | `openai-v<version>` |

To release:

1. Bump the version in the platform's version files and commit.
2. Validate:
   - Claude: `claude plugin validate --strict ./plugins/claude/simple-injection-dashboard --profile directory`
   - OpenAI: confirm the JSON parses and both manifest versions match.
3. Push `main`, then tag the release commit and create the release:
   ```
   gh release create claude-v<version> --target main --title "Claude plugin v<version>" --notes "<changes>"
   gh release create openai-v<version> --target main --title "OpenAI plugin v<version>" --notes "<changes>" <zip>
   ```
   For OpenAI, attach the upload zip, built from the contents of `plugins/openai/simple-injection-dashboard/` and named `simple-injection-dashboard-<version>-openai-upload.zip`. Zips are git-ignored and are never committed.
4. Never reuse or move an existing version tag. Ship a fix as a new version.

Release notes follow the same rule as everything else here: no sensitive information.
