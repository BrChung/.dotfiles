# Zen Browser sync via Syncthing

Sync Zen Spaces, tabs, Essentials, pinned tabs, extensions, and themes between Macs by mirroring the **Zen profile folder** with [Syncthing](https://syncthing.net/).

Mozilla Sync does not replicate Zen's workspace session state. This setup is a **profile handoff**: one Mac uses Zen at a time, then syncs before switching.

Based on the [r/zen_browser "Ghost Sync" approach](https://www.reddit.com/r/zen_browser/comments/1pl2wqq/i_just_figured_out_how_to_fully_sync_zen_browser/).

## Critical: sync the profile folder only

**Do not sync** `~/Library/Application Support/zen/` (the whole tree).

Sync only your profile directory, e.g.:

```
~/Library/Application Support/zen/Profiles/wimanhmx.Default (release)
```

The zen root contains `profiles.ini` and `installs.ini`, which tell Zen which profile to load. Syncing the whole tree overwrites those files and can point Zen at an empty profile on the other Mac — even when your real data is still on disk.

Find your profile path: Zen → `about:profiles` → **Root Directory**.

Both Macs should use the **same profile folder name** after the first sync (e.g. `wimanhmx.Default (release)` on both).

## What gets synced

| Synced | Not synced (ignored) |
|--------|----------------------|
| Spaces / workspaces | Cache directories |
| Open tabs, pinned tabs, Essentials | Lock files (`parent.lock`) |
| `sessionstore.jsonlz4`, `zen-sessions.jsonlz4` | Session backup folders |
| Extensions and themes | Crash reports |

Zen needs **both** `sessionstore.jsonlz4` and `zen-sessions.jsonlz4` in the profile folder.

## How it works

```
MacBook A                                              MacBook B
~/Library/.../zen/Profiles/wimanhmx...  ←────→  ~/Library/.../zen/Profiles/wimanhmx...
              ↑                                                    ↑
         Syncthing (P2P)                                     Syncthing (P2P)
              ↑                                                    ↑
         Dock → Zen → Cmd+Q                               Dock → Zen → Cmd+Q
              └── zen-sync-watch triggers scan after quit ─────────┘
```

Syncthing keeps a local copy on each Mac. There is no cloud storage unless you add a third device (NAS, etc.).

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
| Label | `zen-browser` |
| Path | `~/Library/Application Support/zen/Profiles/<your-profile>.Default (release)` |

**Enable File Versioning** (Folder → Edit → File Versioning → Staggered, keep ~10 versions).

Share the folder with your second Mac after pairing devices.

### 2. Ignore patterns

Folder → Edit → Ignore Patterns → paste contents of:

```
~/.config/zen-syncthing/zen.ignore
```

### 3. Disable auto-watch

Folder → Advanced:

- Uncheck **Watch for Changes**
- Set **Full Rescan Interval** to `0`

Also: Actions → Advanced → Folders → disable **Fs Watcher**.

Sync should only run when `zen-sync-watch` triggers it after you quit Zen.

### 4. Local config

`./install` symlinks `~/.config/zen-syncthing/env` → `config/zen-syncthing/env` (gitignored, machine-local).

| Variable | Where to find it |
|----------|------------------|
| `SYNCTHING_API_KEY` | Syncthing → Actions → Settings → General (auto-filled by `./install`) |
| `SYNCTHING_FOLDER_ID` | Syncthing → Folders → zen-browser → Folder ID |
| `ZEN_PROFILE_DIR` | Zen → `about:profiles` → Root Directory |

### 5. Pair the second Mac

On Mac 1: Actions → Show ID → copy device ID.

On Mac 2:

1. Run `./install`
2. Add Remote Device with Mac 1's ID
3. Accept the shared folder (same profile path on Mac 2)
4. Apply the same ignore patterns, versioning, and Advanced settings
5. Set `SYNCTHING_FOLDER_ID` in `~/.config/zen-syncthing/env`

**Before opening Zen on Mac 2 for the first time**, edit `~/Library/Application Support/zen/profiles.ini` so Profile0 points at the synced profile:

```ini
[Profile0]
Name=Default (release)
IsRelative=1
Path=Profiles/wimanhmx.Default (release)
```

Also set the install section if present:

```ini
[Install6ED35B3CA1B5D3AF]
Default=Profiles/wimanhmx.Default (release)
Locked=1
```

Verify with `about:profiles` before browsing. Delete any empty stray profile folders (e.g. from a fresh install) to avoid confusion.

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
2. Wait for sync (check log or Syncthing UI — folder should show idle, 0 bytes out of sync)
3. **Mac B:** open Zen from Dock → same Spaces and tabs

## Rules

1. **One Mac at a time** — never run Zen on both Macs simultaneously
2. **Always Cmd+Q** — don't force-quit; Zen writes session state on clean exit
3. **Wait for sync** — don't open Zen on the other Mac until sync finishes
4. **Match Zen versions** — upgrade both Macs together after major updates
5. **Sign out of Mozilla Sync** — avoids conflicts with bookmarks, passwords, and prefs
6. **Profile folder only** — never point Syncthing at the whole `zen/` directory

## Troubleshooting

### Spaces or tabs missing (but data may still be on disk)

1. Zen → `about:profiles` — confirm you're on the right profile (not an empty fresh-install profile)
2. Check `~/Library/Application Support/zen/profiles.ini` — `Path=` must match your real profile folder
3. Check `~/Library/Application Support/zen/installs.ini` — `Default=` must match too
4. Session files live in the profile folder: both `zen-sessions.jsonlz4` and `sessionstore.jsonlz4` must exist

### `Couldn't load XPCOM`

You ran `zen` (Homebrew binary) instead of opening from the Dock. Use `open -a Zen` or `zensync`.

### Sync never completes

- Check both Macs are online and paired in http://127.0.0.1:8384
- Confirm `SYNCTHING_FOLDER_ID` is set in `~/.config/zen-syncthing/env`
- Ensure Zen is closed on both Macs during sync

### Lost tabs

Restore from Zen's local session backup:

1. Quit Zen
2. Open profile folder: Zen → `about:support` → Profile Directory → Open Directory
3. See [Zen session recovery docs](https://docs.zen-browser.app/user-manual/window-sync#session-backup-system-on-zen-v118-onwards)

Restore **both** `zen-sessions.jsonlz4` (from `zen-sessions-backup/`) and `sessionstore.jsonlz4` (from `sessionstore-backups/`).

## Why not Mozilla Sync?

Mozilla Sync handles bookmarks, passwords, and history. Zen-specific data (Spaces, tabs inside Spaces, Essentials layout) is stored in session files Firefox Sync does not replicate across devices.

## Why not iCloud Drive on the profile folder?

Two writers (Zen + iCloud) touching the same SQLite and session files causes corruption. Syncthing with manual trigger-on-quit avoids syncing while Zen is open.
