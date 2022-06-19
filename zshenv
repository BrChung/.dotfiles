# Set Variables
export NULLCMD=bat
export HOMEBREW_CASK_OPTS="--no-quarantine"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


function exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1

  # More explicitly written:
  # command -v $1 1>/dev/null 2>/dev/null
}

. "$HOME/.cargo/env"
