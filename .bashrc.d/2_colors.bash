#################
#COLORS
#################

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors.256dark && eval "$(dircolors -b ~/.dircolors.256dark)" || eval "$(dircolors -b)"
fi
DC=$(printf "%s" echo $LS_COLORS | grep -oP ':di=(\d+;\d+)' | awk -F= '{ print $2 }')
DIRC="\033[${DC}m"
