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

was_running=false
syncing=false

while true; do
  if zen_sync_is_running; then
    was_running=true
    syncing=false
  elif $was_running && ! $syncing; then
    was_running=false
    syncing=true
    zen_sync_after_quit || true
    syncing=false
  fi
  sleep 2
done
