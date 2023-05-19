# Put my perl scripts in my PATH.

if [ -d "$HOME/perl" ] ; then
    PATH="$HOME/perl:$PATH"
fi

# Add my perl lib to PERL5LIB.

if [ -d "$HOME/perl/lib" ] ; then
	PERL5LIB="${PERL5LIB:+"$PERL5LIB:"}$HOME/perl/lib"
	export PERL5LIB
fi

# Enable plenv.

if [ -d "$HOME/.plenv/bin" ] ; then
    PATH="$HOME/.plenv/bin:$PATH"
	eval "$(plenv init -)"
fi

# Enable Rakudobrew

if [ -d "$HOME/.rakudobrew/bin" ] ; then
    PATH="$HOME/.rakudobrew/bin:$PATH"
	export PATH
fi
