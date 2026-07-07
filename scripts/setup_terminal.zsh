#!/usr/bin/env zsh

echo "\n<<< Starting Terminal Setup >>>\n"

TERMINAL_FONT="Hack Nerd Font Mono"
TERMINAL_FONT_SIZE=13
ITERM_FONT="HackNFM-Regular ${TERMINAL_FONT_SIZE}"

if [[ -d /System/Applications/Utilities/Terminal.app ]]; then
  echo "Setting Terminal.app font for all profiles..."
  osascript <<APPLESCRIPT
tell application "Terminal"
  repeat with p in settings sets
    set font name of p to "${TERMINAL_FONT}"
    set font size of p to ${TERMINAL_FONT_SIZE}
  end repeat
end tell
APPLESCRIPT
  echo "Terminal.app font set to ${TERMINAL_FONT} ${TERMINAL_FONT_SIZE}pt"
fi

if [[ -d /Applications/iTerm.app ]]; then
  iterm_plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  iterm_dynamic_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  iterm_dynamic_link="$iterm_dynamic_dir/dotfiles.json"

  if [[ -L "$iterm_dynamic_link" ]]; then
    rm "$iterm_dynamic_link"
  fi

  if [[ -f "$iterm_plist" ]]; then
    echo "Setting iTerm2 font for all profiles..."
    osascript -e 'tell application "iTerm" to quit' 2>/dev/null || true
  fi

  python3 - "$iterm_plist" "$ITERM_FONT" <<'PY'
import plistlib
import sys
from pathlib import Path

plist_path = Path(sys.argv[1])
font = sys.argv[2]

if not plist_path.exists():
    print("iTerm2 preferences not found — open iTerm2 once, then re-run ./install")
    sys.exit(0)

with plist_path.open("rb") as f:
    data = plistlib.load(f)

profiles = data.get("New Bookmarks", [])
if not profiles:
    print("No iTerm2 profiles found")
    sys.exit(0)

for profile in profiles:
    profile["Normal Font"] = font
    profile["Non Ascii Font"] = font
    profile["Use Non-ASCII Font"] = False

profiles = [p for p in profiles if p.get("Name") != "Dotfiles"]
data["New Bookmarks"] = profiles

with plist_path.open("wb") as f:
    plistlib.dump(data, f)

default_guid = profiles[0].get("Guid", "")
if default_guid:
    data["Default Bookmark Guid"] = default_guid

with plist_path.open("wb") as f:
    plistlib.dump(data, f)

print(f"iTerm2 font set to {font} on {len(profiles)} profile(s)")
PY
fi
