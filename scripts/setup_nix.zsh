#!/usr/bin/env zsh

echo "\n<<< Starting Nix Setup >>>\n"

load_nix_shellenv() {
  local nix_daemon_sh="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  if [[ -r "$nix_daemon_sh" ]]; then
    source "$nix_daemon_sh"
  fi
}

if command -v nix &>/dev/null; then
  echo "nix exists, skipping install"
else
  echo "nix doesn't exist, continuing with install"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

load_nix_shellenv

if ! command -v nix &>/dev/null; then
  echo "nix is not available on PATH after install"
  exit 1
fi

echo "Installed $(nix --version)"
