# Set path
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Debug zsh startup time
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# Set colours
export TERM="xterm-256color"

# Antibody
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
alias antibody_update='antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh'
if [[ -n ~/.zsh_plugins.txt(#qN.mh+24) ]]; then
    antibody_update
fi
export ZSH="$(antidote home)/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh"
source ~/.zsh_plugins.sh

# Completion
fpath=($fpath ~/.zsh/completion)
autoload -U compinit && compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi

# Source all files in ~/.zshrc.d/
for i in ~/.zshrc.d/* ; do
    if [ -r "$i" ]; then
        source $i
    fi
done

if [[ -n "$ZSH_DEBUGRC" ]]; then
  zprof
fi

