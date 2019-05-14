# Alias definitions.

# Program aliases.

alias gv='/usr/bin/gvim'
alias hex='/usr/bin/bless'

# Package management.

alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'
alias install='sudo apt-get install' 
alias remove='sudo apt-get remove' 

# Frequently used directories and directory traversal.

alias d='dirs'
alias dirc='builtin dirs -c'
alias downd='pushd -1'
alias desktop='cd ~/Desktop' 
alias downloads='cd ~/Downloads' 
alias dropbox='cd ~/Dropbox'
alias home='cd ~'
alias stack='dirc && cd'
alias upd='pushd +1'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'

# docker aliases
alias dk='docker kill $(docker ps -q)'         # docker kill all images
alias dp='docker system prune -f'              # prune everything
alias drmi='docker rmi $(docker images -q -a)' # delete untagged images
alias dsc='docker rm $(docker ps -a -q)'       # delete all stopped containers
alias dvc='docker volume rm $(docker volume ls -qf dangling=true)' # remove dangling volumes
alias dc='dk; dsc; drmi; dvc; dp'              # clean everything

# git aliases
alias gb='git branch'
alias gc='git checkout'
alias gd='git diff'
alias gp='git pull'
alias gs='git status'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep -i --color=auto'
    alias fgrep='fgrep -i --color=auto'
    alias egrep='egrep -i --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# random aliases
alias rxrx="perl -MRegexp::Debugger -E 'Regexp::Debugger::rxrx(@ARGV)'"
alias spacehog='du -sh * | sort -h'
alias src='source ~/.bashrc'
alias tmpclean='sudo find /tmp -ctime +10 -exec rm -rf {} +'
