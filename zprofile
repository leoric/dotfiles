# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

export LANG="en_US.UTF-8"
export BLOCK_SIZE=human-readable

# Terminal colors
export CLICOLOR=1
export COLORTERM=truecolor

# ======== LESS (BETTER PAGING) ========
export LESS="-RFX"
export LESSHISTFILE="-"

# ======== MANPAGER (BETTER MAN PAGES) ========
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export PAGER="less"

# Project virtual environment configuration
export PRO_PROJECT_ROOT="$HOME/pro"
export PYTHON_DEFAULT_VENV="$HOME/.venv"

# FZF
#export FZF_DEFAULT_OPTS='--multi'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'     # Default file search command (requires ripgrep)

# PATH
typeset -U path
path=(
    "$HOME/.local/bin"
    "$PYTHON_DEFAULT_VENV/bin"
    "$HOME/.spoofdpi/bin"
    "$HOME/MEGA/IT/bin"
    $path
)

# Colors: prefer eza theme, otherwise use vivid
if [[ -s "$HOME/.config/eza/theme.yml" ]]; then
    unset LS_COLORS EZA_COLORS EXA_COLORS
elif command -v vivid >/dev/null 2>&1; then
    export LS_COLORS="$(vivid generate gruvbox-dark)"
elif [[ -x /usr/bin/dircolors ]]; then
    # Linux fallback (from vanilli.sh): honor ~/.dircolors, else built-in defaults
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
fi

umask 002
