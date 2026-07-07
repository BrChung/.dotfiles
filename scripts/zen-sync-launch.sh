#!/usr/bin/env bash
set -euo pipefail

script_path="${BASH_SOURCE[0]}"
while [ -h "$script_path" ]; do
  dir="$(cd -P "$(dirname "$script_path")" && pwd)"
  script_path="$(readlink "$script_path")"
  [[ "$script_path" != /* ]] && script_path="$dir/$script_path"
done
SCRIPT_DIR="$(cd -P "$(dirname "$script_path")" && pwd)"

# shellcheck source=zen-sync-common.sh
source "$SCRIPT_DIR/zen-sync-common.sh"

if zen_sync_is_running; then
  zen_sync_die "Zen is already running. Quit it first (Cmd+Q), then use this launcher."
fi

echo "Launching Zen… (sync runs after you quit with Cmd+Q)"
open -a Zen -W

zen_sync_after_quit
