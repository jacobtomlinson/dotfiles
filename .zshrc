# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set path
export PATH="$HOME/.local/bin:$HOME/miniconda3/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

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


# >>> nvwb
# Sourcing the nvwb wrapper function was added during the NVIDIA AI Workbench installation and
# is required for NVIDIA AI Workbench to function properly. When uninstalling
# NVIDIA AI Workbench, it will be removed. 

source $HOME/.local/share/nvwb/nvwb-wrapper.sh
# >>> nvwb
