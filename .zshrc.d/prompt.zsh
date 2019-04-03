if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="cyan"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

PROMPT='%{$fg[$NCOLOR]%}%n%{$reset_color%}@%{$fg[green]%}%m\
%{$reset_color%}:\
%{$fg[magenta]%}%1d%{$reset_color%}\
$(git_super_status) \
$(kube_ps1)\

%{$fg[red]%}%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%} ["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}%{✔%G%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[magenta]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_BEHIND"
ZSH_THEME_GIT_PROMPT_AHEAD="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_AHEAD"
ZSH_THEME_GIT_PROMPT_UNTRACKED="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_UNTRACKED"

function get_cluster_short() {
  echo "$1" | cut -d . -f1
}

KUBE_PS1_DIVIDER=" "
KUBE_PS1_SEPARATOR=""
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
