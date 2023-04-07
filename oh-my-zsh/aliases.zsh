# My custom aliases for zsh

alias ls='exa'
alias exa='exa -laFh --git'
alias bbd='brew bundle dump --force --describe'
# Prety print PATH variable (echo $PATH)
alias trail='<<<${(F)path}'
alias readlink='greadlink'