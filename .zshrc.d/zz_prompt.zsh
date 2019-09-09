# Names zz so that it is last to load

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{red]}%(!.#.»)%f "

OS_ICON=""
POWERLEVEL9K_APPLE_ICON=""

DEFAULT_USER="jtomlinson"

POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
POWERLEVEL9K_STATUS_OK="false"

POWERLEVEL9K_CUSTOM_ANACONDA='powerline_anaconda'
POWERLEVEL9K_CUSTOM_ANACONDA_BACKGROUND="seagreen3"
POWERLEVEL9K_CUSTOM_ANACONDA_FOREGROUND="grey23"

POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD="20"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon ssh context dir custom_anaconda vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time root_indicator background_jobs battery)

# if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="cyan"; fi
# local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# PROMPT='%{$fg[$NCOLOR]%}%n%{$reset_color%}@%{$fg[green]%}%m\
# %{$reset_color%}:\
# %{$fg[magenta]%}%1d%{$reset_color%}\
# $(git_super_status) \
# $(kube_ps1)\

# %{$fg[red]%}%(!.#.»)%{$reset_color%} '
# PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
# RPS1='${return_code}'

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%} ["
# ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%}]%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
# ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[yellow]%}"
# ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}%{✔%G%}"
# ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[magenta]%}%{●%G%}"
# ZSH_THEME_GIT_PROMPT_BEHIND="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_BEHIND"
# ZSH_THEME_GIT_PROMPT_AHEAD="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_AHEAD"
# ZSH_THEME_GIT_PROMPT_UNTRACKED="$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_UNTRACKED"

# function get_cluster_short() {
#   echo "$1" | cut -d . -f1
# }

# KUBE_PS1_DIVIDER=" "
# KUBE_PS1_SEPARATOR=""
# KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
