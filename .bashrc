# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# http://blog.sanctum.geek.nz/shell-config-subfiles/
# Load any supplementary scripts
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [[ -d $HOME/.bashrc.d ]] ; then
	for config in "$HOME"/.bashrc.d/*.bash ; do
		source "$config"
	done
fi

unset -v config

export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64:/bin/gcc:/opt/local/glibc-2.18/lib

# Setup Java.
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=$PATH:$M2_HOME/bin:$JAVA_HOME/bin

# Setup Python.
export PYENV_ROOT=/home/rmknigh/.pyenv
PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Setup Kotlin.  KOTLIN_HOME is set by snapd.
#export KOTLIN_HOME=/var/lib/snapd/snap/bin/kotlin
export PATH=$PATH:$KOTLIN_HOME


# Deduplicate PATH.
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
