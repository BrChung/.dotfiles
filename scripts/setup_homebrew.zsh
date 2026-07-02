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

vscode_code() {
  if command -v code &>/dev/null; then
    code "$@"
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$@"
  else
    return 1
  fi
}

retry_flaky_bundle_installs() {
  local failed=0

  if ! brew list zstd &>/dev/null; then
    echo "Retrying zstd install..."
    brew install zstd || failed=1
  fi

  if ! vscode_code --version &>/dev/null; then
    echo "VS Code CLI not available — skipping extension retries"
  else
    local ext
    for ext in ms-python.python ms-python.debugpy ms-toolsai.jupyter dart-code.dart-code; do
      if ! vscode_code --list-extensions 2>/dev/null | grep -Fxq "$ext"; then
        echo "Retrying VS Code extension: $ext"
        vscode_code --install-extension "$ext" || failed=1
      fi
    done
  fi

  return $failed
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

# Homebrew 5+ requires trusting third-party casks before install
if brew tap 2>/dev/null | grep -q '^bell-sw/liberica$'; then
  brew trust bell-sw/liberica 2>/dev/null || true
fi

# Install from Brewfile
# TODO: Custom brew files for configs
bundle_failed=0
brew bundle --verbose || bundle_failed=1

if (( bundle_failed )); then
  echo "brew bundle reported failures — retrying known flaky installs..."
  retry_flaky_bundle_installs || exit 1
fi
