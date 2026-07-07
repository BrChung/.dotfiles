#!/usr/bin/env zsh

echo "\n<<< Starting Node Setup >>>\n"

load_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

load_brew_shellenv

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
elif [[ ! -d "$NVM_DIR/versions/node" ]] || [[ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]]; then
  echo "nvm not found — ensure Homebrew setup completed successfully"
  exit 1
fi

# Node versions are managed with `nvm`, which is in the Brewfile.
if [[ ! -d "$NVM_DIR/versions/node" ]] || [[ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]]; then
  echo "No node versions found, installing LTS..."
  nvm install --lts
else
  echo "Found node installation"
fi

read "response?Do you wish to install global npm packages? [Y/n] "
response=${response:l} #tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

  # Install Global NPM Packages
  npm install -g @angular/cli
  npm install -g npmrc
  npm install -g corepack
  corepack enable

  echo "Global NPM Packages Installed:"
  npm list --global --depth=0
fi
