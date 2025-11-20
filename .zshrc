# Set path
export PATH="$HOME/.zsh/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Debug zsh startup time
if [[ -n "$ZSH_DEBUGRC" ]]; then
  zmodload zsh/zprof
fi

# Set colours
export TERM="xterm-256color"

# Antidote
for f in "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" "$HOME/.antidote/antidote.zsh"; do 
  if [ -f "$f" ]; then
    ANTIDOTE_INIT_PATH="$f"
    break
  fi
done

if [ ! -n "$ANTIDOTE_INIT_PATH" ]; then
  echo "Antidote could not be found, installing..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  ANTIDOTE_INIT_PATH="$HOME/.antidote/antidote.zsh"
fi
source "$ANTIDOTE_INIT_PATH"
if [[ -n ~/.zsh_plugins.txt(#qN.mh+24) ]]; then
    antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
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

