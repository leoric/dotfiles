# Gruvbox dark HARD palette (truecolor)
local bg0h='#1d2021'   # hard background (also used as text on bright segments)
local bg0='#282828'
local bg1='#3c3836'
local bg2='#504945'
local bg3='#665c54'
local bg4='#7c6f64'
local fg='#ebdbb2'
local gray='#928374'
local red='#fb4934'
local green='#b8bb26'
local yellow='#fabd2f'
local blue='#83a598'
local purple='#d3869b'
local aqua='#8ec07c'
local orange='#fe8019'

local rosewater='#f5e0dc'
local flamingo='#f2cdcd'
local pink='#f5c2e7'
local mauve='#cba6f7'
local maroon='#eba0ac'
local peach='#fab387'
local teal='#94e2d5'
local sky='#89dceb'
local sapphire='#74c7ec'
local lavender='#b4befe'

# Fallback for any segment not listed below
typeset -g POWERLEVEL9K_BACKGROUND=$bg1
typeset -g POWERLEVEL9K_FOREGROUND=$fg

# Directory
typeset -g POWERLEVEL9K_DIR_BACKGROUND=$bg2
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$fg
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$gray
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$yellow
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# Git
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$aqua
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$yellow
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$peach
typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$red
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$bg3
typeset -g POWERLEVEL9K_VCS_FOREGROUND=$bg0h

# Status / exit code
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$green
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=$bg2
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$red

# Command execution time, background jobs, time
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$sapphire
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$aqua
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$bg1
typeset -g POWERLEVEL9K_TIME_FOREGROUND=$fg
typeset -g POWERLEVEL9K_TIME_BACKGROUND=$bg1

# User / host / context
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$fg
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$bg1
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$red
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=$bg0

# Language/tool versions and environments
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$rosewater
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=$green
typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_PYENV_BACKGROUND=$aqua
typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=$blue
typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_RUST_VERSION_BACKGROUND=$orange
typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=$bg0h
typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND=$purple

# Prompt character (the ❯)
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$red

# Separators and multiline connectors
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=$bg3
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_PREFIX_FOREGROUND=$bg3
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_SUFFIX_FOREGROUND=$bg3
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR_FOREGROUND=$bg4
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR_FOREGROUND=$bg4
