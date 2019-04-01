# Set path
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/boxen/homebrew/bin"

# Path to your oh-my-zsh installation.
export ZSH=/Users/jacob/.oh-my-zsh

# Start tmux on login
# export ZSH_TMUX_AUTOSTART=true

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git github git-extras aws docker nyan osx pip python screen sudo tmux command-time)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Completion
autoload -U compinit && compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

zmodload -i zsh/complist
fpath=($fpath ~/.zsh/completion)

# Source all files in ~/.zshrc.d/
for i in ~/.zshrc.d/* ; do
    if [ -r "$i" ]; then
        source $i
    fi
done
