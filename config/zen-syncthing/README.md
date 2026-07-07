# Zen Browser sync via Syncthing

Sync Zen Spaces, tabs, Essentials, pinned tabs, extensions, and themes between Macs by mirroring the Zen profile folder with [Syncthing](https://syncthing.net/).

Mozilla Sync does not replicate Zen's workspace session state. This setup is a **profile handoff**: one Mac uses Zen at a time, then syncs before switching.

Based on the [r/zen_browser "Ghost Sync" approach](https://www.reddit.com/r/zen_browser/comments/1pl2wqq/i_just_figured_out_how_to_fully_sync_zen_browser/).

## What gets synced

| Synced | Not synced (ignored) |
|--------|----------------------|
| Spaces / workspaces | Cache directories |
| Open tabs, pinned tabs, Essentials | Lock files (`parent.lock`) |
| Extensions and themes | Session backup folders |
| `prefs.js`, containers | Crash reports |

## How it works

```
MacBook A                                    MacBook B
~/Library/Application Support/zen/  ←────→  ~/Library/Application Support/zen/
              ↑                                        ↑
         Syncthing (P2P)                         Syncthing (P2P)
              ↑                                        ↑
         zensync → Zen → Cmd+Q                  zensync → Zen → Cmd+Q
              └── triggers scan after quit ──────────┘
```

Syncthing keeps a local copy on each Mac. There is no cloud storage unless you add a third device (NAS, etc.).

Files live on your machines only. Relays may forward encrypted traffic between networks but do not store data.

## Prerequisites

- Two Macs with the **same Zen version** (`brew upgrade --cask zen` on both)
- Homebrew
- **Signed out of Mozilla Sync** on both Macs (Zen → Settings → Sync)
- Only **one Mac with Zen open** at a time

## Quick start

Run on each Mac:

```bash
cd ~/.dotfiles && ./install
```

Then finish in the Syncthing web UI at http://127.0.0.1:8384.

### 1. Add the Zen folder (first Mac)

| Setting | Value |
|---------|-------|
| Label | `zen` |
| Path | `~/Library/Application Support/zen` |

Share the folder with your second Mac after pairing devices.

### 2. Ignore patterns

Folder → Edit → Ignore Patterns → paste contents of:

```
~/.config/zen-syncthing/zen.ignore
```

(Source copy lives in this directory as `zen.ignore`.)

### 3. Disable auto-watch

Folder → Advanced:

- Uncheck **Watch for Changes**
- Set **Full Rescan Interval** to `0`

Also: Actions → Advanced → Folders → zen → disable **Fs Watcher**.

Sync should only run when `zensync` triggers it after you quit Zen.

### 4. Local config

`./install` symlinks `~/.config/zen-syncthing/env` → `config/zen-syncthing/env` (gitignored, machine-local). On first install it is seeded from `env.example`.

| Variable | Where to find it |
|----------|------------------|
| `SYNCTHING_API_KEY` | Syncthing → Actions → Settings → General (auto-filled by `./install`) |
| `SYNCTHING_FOLDER_ID` | Syncthing → Folders → zen → Folder ID |

### 5. Pair the second Mac

On Mac 1: Actions → Show ID → copy device ID.

On Mac 2:

1. Run `./install`
2. Add Remote Device with Mac 1's ID
3. Accept the shared `zen` folder
4. Apply the same ignore patterns and Advanced settings
5. Set `SYNCTHING_FOLDER_ID` in `~/.config/zen-syncthing/env`

## Daily use

**From the Dock (recommended):** open and quit Zen normally. A background watcher (`zen-sync-watch`) runs at login via `./install` and triggers Syncthing sync automatically when you **Cmd+Q**.

```bash
# Optional CLI launcher — same sync-on-quit behavior
zensync
```

**Do not run `zen` in the terminal** — Homebrew links that to the browser binary and will fail with `Couldn't load XPCOM`.

Sync progress is logged to `~/Library/Logs/zen-sync-watch.log`.

### Handoff workflow

1. **Mac A:** open Zen from Dock → browse → **Cmd+Q**
2. Wait for sync (check log or Syncthing UI)
3. **Mac B:** open Zen from Dock → same Spaces and tabs

## Rules

1. **One Mac at a time** — never run Zen on both Macs simultaneously
2. **Always Cmd+Q** — don't force-quit; Zen writes session state on clean exit
3. **Wait for sync** — don't open Zen on the other Mac until sync finishes
4. **Match Zen versions** — upgrade both Macs together after major updates
5. **Sign out of Mozilla Sync** — avoids conflicts with bookmarks, passwords, and prefs

## Files in this directory

| File | Purpose |
|------|---------|
| `zen.ignore` | Syncthing ignore patterns (cache, locks, backups) |
| `env.example` | Template seeded into `env` on first install |
| `env` | Machine-local config (gitignored, symlinked to `~/.config/zen-syncthing/env`) |
| `zen-sync-watch.plist` | LaunchAgent template (installed to `~/Library/LaunchAgents/` by `./install`) |
| `README.md` | This doc |

Related scripts (repo root):

| File | Purpose |
|------|---------|
| `scripts/zen-sync-watch.sh` | Background watcher — syncs after Zen quits (Dock or CLI) |
| `scripts/zen-sync-launch.sh` | Optional CLI launcher with sync-on-quit |
| `scripts/zen-sync-trigger.sh` | Manual sync trigger (`zen-sync-trigger`) |

Local config (gitignored, symlinked by `./install`):

```
~/.config/zen-syncthing/env        → config/zen-syncthing/env
~/.config/zen-syncthing/zen.ignore → config/zen-syncthing/zen.ignore
~/bin/zen-sync-watch               → scripts/zen-sync-watch.sh
~/bin/zensync                      → scripts/zen-sync-launch.sh
~/Library/LaunchAgents/co.brianchung.zen-sync-watch.plist
```

Edit `config/zen-syncthing/env` directly (or via the symlink).

## Troubleshooting

### `Couldn't load XPCOM`

You ran `zen` (Homebrew binary) instead of `zensync`. Use:

```bash
zensync
# or
open -a Zen
```

### `Zen is already running`

Quit Zen with Cmd+Q, then run `zensync` again.

### `Syncthing is not running`

```bash
brew services start syncthing
```

### Sync never completes

- Check both Macs are online and paired in http://127.0.0.1:8384
- Confirm `SYNCTHING_FOLDER_ID` is set in `~/.config/zen-syncthing/env`
- Ensure Zen is closed on both Macs during sync

### Spaces or tabs missing after sync

- Verify both Macs run the same Zen version
- Confirm you waited for sync to finish before opening Zen on the other Mac
- Check Syncthing for conflicts or errors on the `zen` folder

### Lost tabs

Restore from Zen's local session backup:

1. Quit Zen
2. Open profile folder: Zen → `about:support` → Profile Directory → Open Directory
3. See [Zen session recovery docs](https://docs.zen-browser.app/user-manual/window-sync#session-backup-system-on-zen-v118-onwards)

Enable Syncthing **File Versioning** on the `zen` folder for extra safety.

## Why not Mozilla Sync?

Mozilla Sync handles bookmarks, passwords, and history. Zen-specific data (Spaces, tabs inside Spaces, Essentials layout) is stored in session files Firefox Sync does not replicate across devices. Native Zen workspace sync is still in progress.

## Why not iCloud Drive on the profile folder?

Two writers (Zen + iCloud) touching the same SQLite and session files causes corruption. Syncthing with manual trigger-on-quit avoids syncing while Zen is open.
