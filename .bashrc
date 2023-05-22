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

export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64:/bin/gcc

# Setup Golang.
export GOROOT=/var/lib/snapd/snap/go/current
#export GOPATH=/path/to/go/packages
export PATH=$PATH:$GOROOT/bin

# Seeup Gradle.
export GRADLE_HOME=/var/lib/snapd/snap/gradle/current/opt/gradle
export PATH=$PATH:$GRADLE_HOME/bin

# Setup Java.
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=$PATH:$M2_HOME/bin:$JAVA_HOME/bin

# Setup Python.
export PYENV_ROOT=$HOME/.pyenv
PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Setup Kotlin.
export KOTLIN_HOME=/var/lib/snapd/snap/kotlin/current
export PATH=$PATH:$KOTLIN_HOME/bin

# Deduplicate PATH.
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')

# May need to clean up the following if running setup script on multiple boxes.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
