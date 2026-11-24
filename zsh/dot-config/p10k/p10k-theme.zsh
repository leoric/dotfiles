# Detect dark/light mode.
function _terminal_is_dark() {
  # iTerm2 sets COLORFGBG ("fg;bg") at session start; bg < 8 means dark.
  if [[ -n "$COLORFGBG" ]]; then
    local bg="${COLORFGBG##*;}"
    if [[ "$bg" == <-> ]]; then
      (( bg < 8 ))
      return
    fi
  fi

  # Fallback: macOS system appearance.
  if [[ "$OSTYPE" == darwin* ]]; then
    [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]]
    return
  fi

  return 0  # default to dark
}

if _terminal_is_dark; then
    # Gruvbox dark HARD palette (truecolor)
    local bg0h='#1d2021'   # hard background (also used as text on bright segments)
    local bg0='#282828'
    local bg1='#3c3836'
    local bg2='#504945'
    local bg3='#665c54'
    local bg4='#7c6f64'
    local fg='#ebdbb2'
    local gray='#a89984'
    local red='#fb4934'
    local green='#b8bb26'
    local yellow='#fabd2f'
    local blue='#83a598'  # more like cyan
    local purple='#d3869b'
    local aqua='#8ec07c'
    local orange='#fe8019'

    local rosewater='#f5e0dc'
    local flamingo='#f2cdcd'
    local pink='#f5c2e7'
    local mauve='#cba6f7'
    local maroon='#eba0ac'
    local peach='#fab387'
    local sky='#89dceb'
    local sapphire='#74c7ec'
    local lavender='#b4befe'
else
    # Stark Light palette for powerlevel10k
    typeset -g bg0h='#fdfcfa'      # editor.background
    typeset -g bg0='#f8f6f3'       # editorWidget.background
    typeset -g bg1='#f3f0eb'       # statusBar / sideBarSectionHeader
    typeset -g bg2='#e6e1da'       # borders, list.activeSelection
    typeset -g bg3='#ddd8d1'       # button.secondaryHover
    typeset -g bg4='#c4bfb8'       # line numbers, indent guide active
    typeset -g fg='#3d3a36'        # editor.foreground
    typeset -g gray='#9a948c'      # inactive foreground / placeholder

    # gruvbox-style accents
    typeset -g red='#c75a4d'
    typeset -g green='#5a9a52'
    typeset -g yellow='#b8943a'
    typeset -g blue='#5a7cc7'
    typeset -g purple='#9b6bb8'
    typeset -g aqua='#4a9a9a'
    typeset -g orange='#8a603f'

    # catppuccin-style accents
    typeset -g rosewater='#efc0b8' # derived (lighter red/pink)
    typeset -g flamingo='#e8a59c'  # terminal.ansiBrightRed
    typeset -g pink='#d4b8e8'      # terminal.ansiBrightMagenta
    typeset -g mauve='#7c5cba'     # accent (cursor, buttons)
    typeset -g maroon='#c75a5a'    # markup.bold
    typeset -g peach='#c78a5a'     # lighter orange
    typeset -g sky='#98d4d4'       # terminal.ansiBrightCyan
    typeset -g sapphire='#5a9ac7'  # derived (between aqua and blue)
    typeset -g lavender='#9b8ac4'  # focusBorder
fi

# Fallback for any segment not listed below
typeset -g POWERLEVEL9K_BACKGROUND=$bg1
typeset -g POWERLEVEL9K_FOREGROUND=$fg

# Directory
typeset -g POWERLEVEL9K_DIR_BACKGROUND=$bg2
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$fg
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$gray
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$orange
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# Git
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$aqua
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$yellow
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$lavender
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
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$blue
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
typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=$sapphire
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
