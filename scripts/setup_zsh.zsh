#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"

# By this point latest zsh should be installed by brew

# Check if oh-my-zsh is installed
OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo 'Updating oh-my-zsh'
  upgrade_oh_my_zsh
fi

# Add homebrew zsh as an available login shell option
# https://stackoverflow.com/a/4749368/1341838
if grep -Fxq "$HOMEBREW_PREFIX/bin/zsh" '/etc/shells'; then
  echo "$HOMEBREW_PREFIX/bin/zsh already exists in /etc/shells"
else
  echo "Enter superuser (sudo) password to edit /etc/shells"
  echo "$HOMEBREW_PREFIX/bin/zsh" | sudo tee -a '/etc/shells' >/dev/null
fi

# Change shell to zsh installed by homebrew
if [ "$SHELL" = "$HOMEBREW_PREFIX/bin/zsh" ]; then
  echo "$SHELL is already $HOMEBREW_PREFIX/bin/zsh"
else
  echo "Enter user password to change login shell"
  chsh -s "$HOMEBREW_PREFIX/bin/zsh"
fi

# Use ZSH instead of BASH for detault shell
# if sh --version | grep -q zsh; then
#   echo '/private/var/select/sh already linked to /bin/zsh'
# else
#   echo "Enter superuser (sudo) password to symlink sh to zsh"
#   # Looked cute, might delete later, idk
#   sudo ln -sfv /bin/zsh /private/var/select/sh

#   # I'd like for this to work instead.
#   # sudo ln -sfv /usr/local/bin/zsh /private/var/select/sh
# fi