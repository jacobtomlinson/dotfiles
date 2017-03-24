# Path to your oh-my-zsh installation.
export ZSH=/Users/jacob/.oh-my-zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git git-extras)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

autoload -U compinit && compinit
zmodload -i zsh/complist

# Source all files in ~/.zshrc.d/
for i in ~/.zshrc.d/* ; do
    if [ -r "$i" ]; then
        source $i
    fi
done
