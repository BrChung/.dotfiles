#!/usr/bin/env zsh

echo "\n<<< Starting Homebrew Setup >>>\n"

load_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_brew_shellenv_in_zprofile() {
  local brew_bin shellenv_line
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      shellenv_line="eval \"\$($brew_bin shellenv)\""
      if ! grep -Fq "$brew_bin shellenv" "$HOME/.zprofile" 2>/dev/null; then
        echo "$shellenv_line" >> "$HOME/.zprofile"
      fi
      return 0
    fi
  done
  return 1
}

if command -v brew &>/dev/null; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew_shellenv_in_zprofile
fi

load_brew_shellenv

if ! command -v brew &>/dev/null; then
  echo "brew is not available on PATH after install"
  exit 1
fi

# Install from Brewfile
# TODO: Custom brew files for configs

# Homebrew 5+ requires trusting third-party casks before install
if brew tap 2>/dev/null | grep -q '^bell-sw/liberica$'; then
  brew trust bell-sw/liberica 2>/dev/null || true
fi

brew bundle --verbose