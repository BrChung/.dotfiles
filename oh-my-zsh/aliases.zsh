# My custom aliases for zsh

alias ls='lsd'
alias bbd='brew bundle dump --force --describe'
# Prety print PATH variable (echo $PATH)
alias trail='<<<${(F)path}'
alias readlink='greadlink'
# Use zensync — not `zen` (Homebrew links that to the browser binary)
alias zensync='zen-sync-launch'