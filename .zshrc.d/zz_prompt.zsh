# Named zz so that it is last to load

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{red]}%(!.#.»)%f "

OS_ICON="●"
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
