#!/usr/bin/env bash
# Shared Syncthing sync helpers for zen-sync-launch and zen-sync-watch.

zen_sync_load_config() {
  CONFIG="${ZEN_SYNCTHING_CONFIG:-$HOME/.config/zen-syncthing/env}"
  SYNCTHING_URL="${SYNCTHING_URL:-http://127.0.0.1:8384}"
  SYNCTHING_WAIT_TIMEOUT="${SYNCTHING_WAIT_TIMEOUT:-300}"

  if [[ -f "$CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG"
  fi
}

zen_sync_die() {
  echo "zen-sync: $*" >&2
  exit 1
}

zen_sync_ensure_syncthing() {
  if ! curl -sf "${SYNCTHING_URL}/rest/noauth/health" >/dev/null 2>&1; then
    zen_sync_die "Syncthing is not running. Start it with: brew services start syncthing"
  fi
}

zen_sync_trigger_scan() {
  [[ -n "${SYNCTHING_API_KEY:-}" ]] || zen_sync_die "Set SYNCTHING_API_KEY in $CONFIG"
  [[ -n "${SYNCTHING_FOLDER_ID:-}" ]] || zen_sync_die "Set SYNCTHING_FOLDER_ID in $CONFIG"

  curl -sf \
    -H "X-API-Key: ${SYNCTHING_API_KEY}" \
    -X POST "${SYNCTHING_URL}/rest/db/scan?folder=${SYNCTHING_FOLDER_ID}" \
    >/dev/null
}

zen_sync_wait_for_completion() {
  local folder_id="$1"
  local deadline=$((SECONDS + SYNCTHING_WAIT_TIMEOUT))

  while (( SECONDS < deadline )); do
    local status
    status="$(curl -sf \
      -H "X-API-Key: ${SYNCTHING_API_KEY}" \
      "${SYNCTHING_URL}/rest/db/status?folder=${folder_id}")"

    local state need_bytes
    state="$(python3 -c "import json,sys; print(json.load(sys.stdin).get('state',''))" <<<"$status")"
    need_bytes="$(python3 -c "import json,sys; print(json.load(sys.stdin).get('needBytes',1))" <<<"$status")"

    if [[ "$state" == "idle" && "$need_bytes" == "0" ]]; then
      echo "Syncthing sync complete."
      return 0
    fi

    sleep 2
  done

  echo "zen-sync: sync still running after ${SYNCTHING_WAIT_TIMEOUT}s — check Syncthing UI" >&2
  return 1
}

zen_sync_after_quit() {
  zen_sync_load_config
  echo "Zen closed — triggering Syncthing scan…"
  zen_sync_ensure_syncthing
  zen_sync_trigger_scan
  zen_sync_wait_for_completion "${SYNCTHING_FOLDER_ID}"
}

zen_sync_is_running() {
  pgrep -xq zen
}
