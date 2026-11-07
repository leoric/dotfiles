# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# Locale
export LANG="en_US.UTF-8"

# Terminal colors
export CLICOLOR=1
export COLORTERM=truecolor

# History limits and location
export HISTSIZE=11000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"

# ======== LESS (BETTER PAGING) ========
export LESS="-RFX"
export LESSHISTFILE="-"

# ======== MANPAGER (BETTER MAN PAGES) ========
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export PAGER="less"

# Project virtual environment configuration
export PRO_PROJECT_ROOT="$HOME/pro"
export PRO_VENV="$HOME/py.env"

# PATH
typeset -U path
path=(
  "$HOME/.spoofdpi/bin"
  "$HOME/.local/bin"
  "$HOME/MEGA/IT/bin"
  $path
)

# Colors: prefer eza theme, otherwise use vivid
if [[ -s "$HOME/.config/eza/theme.yml" ]]; then
    unset LS_COLORS EZA_COLORS EXA_COLORS
elif command -v vivid >/dev/null 2>&1; then
    export LS_COLORS="$(vivid generate gruvbox-dark)"
fi

umask 002

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
