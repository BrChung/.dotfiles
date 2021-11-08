#!/usr/bin/env zsh

echo "\n<<< Starting macOS Setup >>>\n"

read "response?Do you wish to overwrite MacOS system preferneces? [y/N] "
response=${response:l} #tolower
if [[ $response =~ ^(no|n| ) ]] || [[ -z $response ]]; then
    exit;
fi


osascript -e 'tell application "System Preferences" to quit'

# Finder > Preferences > General > New Finder windows show:
defaults write com.apple.finder NewWindowTarget -string 'PfLo'
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME"

# System Preferences > Dock
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 60
defaults write com.apple.dock largesize -int 75
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock autohide-delay -float 0.1

# Finish macOS Setup
killall Finder
killall Dock
echo "\n<<< macOS Setup Complete.
    A logout or restart might be necessary. >>>\n"

