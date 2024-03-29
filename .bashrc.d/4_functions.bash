function dirs() {
	echo -en "${DIRC}$(builtin dirs -v)\033[0m\n\n"
}

function cd() {
	if [[ $@ ]]; then
		INDIR=$@
	else
		INDIR=$HOME
	fi

	builtin cd $INDIR && ls
}

function pushd() {
	builtin pushd "$@" > /dev/null && dirs && ls
}

function popd() {
	builtin popd "$@" > /dev/null && dirs && ls
}

function smiley() {
	if [ "$?" -eq "0" ]; then
		echo -e '\e[1;30m\e[102m\xf0\x9f\x98\x8a\e[00m'
	else
		echo -e '\e[1;97m\e[101m\xf0\x9f\x98\x88\e[00m'
	fi
}

function p(){
	eval "pushd +$@"
}

function add(){
	RET=`ssh-add -l`
        MATCH='no identities'
	if [[ $RET =~ $MATCH ]]; then
		RET2=`ps -e | grep ssh-agent`
                echo "${RET2}"
		if [[ ! ${RET2} ]]; then
			eval `ssh-agent -s`
		fi
		eval `ssh-add ~/.ssh/id_rsa`
	fi
}

#function tunnels(){
	#ssh -4 -L 0.0.0.0:<port#>:localhost:<port#> -N -f <user>@<hostIP> -o ServerAliveInterval=5
#}

# Show the current distribution

distribution ()
{
        local dtype
        # Assume unknown
        dtype="unknown"

        # First test against Fedora / RHEL / CentOS / generic Redhat derivative
        if [ -r /etc/rc.d/init.d/functions ]; then
                source /etc/rc.d/init.d/functions
                [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"

        # Then test against SUSE (must be after Redhat,
        # I've seen rc.status on Ubuntu I think? TODO: Recheck that)
        elif [ -r /etc/rc.status ]; then
                source /etc/rc.status
                [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"

        # Then test against Debian, Ubuntu and friends
        elif [ -r /lib/lsb/init-functions ]; then
                source /lib/lsb/init-functions
                [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"

        # Then test against Gentoo
        elif [ -r /etc/init.d/functions.sh ]; then
                source /etc/init.d/functions.sh
                [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"

        # For Mandriva we currently just test if /etc/mandriva-release exists
        # and isn't empty (TODO: Find a better way :)
        elif [ -s /etc/mandriva-release ]; then
                dtype="mandriva"

        # For Slackware we currently just test if /etc/slackware-version exists
        elif [ -s /etc/slackware-version ]; then
                dtype="slackware"

        fi
        echo $dtype
}

# Show the current version of the operating system
ver ()
{
        local dtype
        dtype=$(distribution)

        if [ $dtype == "redhat" ]; then
                if [ -s /etc/redhat-release ]; then
                        cat /etc/redhat-release && uname -a
                else
                        cat /etc/issue && uname -a
                fi
        elif [ $dtype == "suse" ]; then
                cat /etc/SuSE-release
        elif [ $dtype == "debian" ]; then
                lsb_release -a
                # sudo cat /etc/issue && sudo cat /etc/issue.net && sudo cat /etc/lsb_release && sudo cat /etc/os-release # Linux Mint option 2
        elif [ $dtype == "gentoo" ]; then
                cat /etc/gentoo-release
        elif [ $dtype == "mandriva" ]; then
                cat /etc/mandriva-release
        elif [ $dtype == "slackware" ]; then
                cat /etc/slackware-version
        else
                if [ -s /etc/issue ]; then
                        cat /etc/issue
                else
                        echo "Error: Unknown distribution"
                        exit 1
                fi
        fi
}

