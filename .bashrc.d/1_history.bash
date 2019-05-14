# append to the history file, don't overwrite it
shopt -s histappend

HISTCONTROL=ignoreboth HISTSIZE=25000
HISTFILESIZE=5000
export HISTCONTROL
