#!/usr/bin/env bash
# Copies shared/ (skills, assets) into every plugin folder under plugins/.
# Plugin directories install only their own folder and reject symlinks, so the
# shared files are committed as real copies. Edit them in shared/, then run this.
#
#   scripts/sync-shared.sh          update the copies
#   scripts/sync-shared.sh --check  exit 1 if any copy differs from shared/
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
check=false
[[ "${1:-}" == "--check" ]] && check=true

status=0
for plugin in "$root"/plugins/*/*/; do
  for dir in "$root"/shared/*/; do
    name="$(basename "$dir")"
    target="$plugin$name"
    if $check; then
      if ! diff -r "$dir" "$target" >/dev/null 2>&1; then
        echo "out of sync: ${target#"$root"/}" >&2
        status=1
      fi
    else
      rm -rf "$target"
      cp -R "$dir" "$target"
    fi
  done
done

$check && [[ $status -eq 0 ]] && echo "shared files in sync"
exit $status
