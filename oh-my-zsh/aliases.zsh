# My custom aliases for zsh

alias ls='lsd'
alias bbd='brew bundle dump --force --describe'
alias trail='<<<${(F)path}'
alias readlink='greadlink'
caf() {
  if (( $# == 1 )) && [[ $1 == <-> ]]; then
    caffeinate -ims -t "$1"
  else
    caffeinate -ims "$@"
  fi
}