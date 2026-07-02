#!/usr/bin/env zsh

echo "\n<<< Starting Node Setup >>>\n"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Node versions are managed with `nvm`, which is in the Brewfile.
if [[ ! -d "$NVM_DIR/versions/node" ]] || [[ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]]; then
    echo "No node versions found, you can install latest and continue installation by using:"
    echo "nvm install --lts && zsh scripts/setup_node.zsh"
    exit 0
else
    echo "Found node installation"
fi

read "response?Do you wish to install global npm packages? [Y/n] "
response=${response:l} #tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

    # Install Global NPM Packages
    npm install -g @angular/cli
    npm install -g npmrc

    echo "Global NPM Packages Installed:"
    npm list --global --depth=0
fi
