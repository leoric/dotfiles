#!/usr/bin/env bash
#
# Symlink the config files from this repo into $HOME.
#
#   ./install.sh [--tmux] [--nvim] [--dry-run] [-h|--help]
#
# Existing files are moved to <name>.bak (or <name>.bak.<timestamp> if a
# backup already exists). Running the script again is safe: links that
# already point into this repo are left alone.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

DRY_RUN=0
WITH_TMUX=0
WITH_NVIM=0

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Symlinks into \$HOME:
  zshrc-antidote        -> ~/.zshrc
  zprofile              -> ~/.zprofile
  antidote-plugins.txt  -> ~/.zsh_plugins.txt
  includes/             -> ~/.zsh_includes

Options:
  --tmux      also link tmux.conf -> ~/.tmux.conf
  --nvim      also link nvimrc    -> ~/.config/nvim/init.vim
  --dry-run   print what would be done, change nothing
  -h, --help  show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --tmux)    WITH_TMUX=1 ;;
    --nvim)    WITH_NVIM=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

# "path in repo:path relative to $HOME"
LINKS=(
  "zshrc-antidote:.zshrc"
  "zprofile:.zprofile"
  "antidote-plugins.txt:.zsh_plugins.txt"
  "includes:.zsh_includes"
)
if [ "$WITH_TMUX" = 1 ]; then
  LINKS+=("tmux.conf:.tmux.conf")
fi
if [ "$WITH_NVIM" = 1 ]; then
  LINKS+=("nvimrc:.config/nvim/init.vim")
fi

run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

link() {
  local src="$REPO_DIR/$1"
  local dest="$HOME/$2"

  if [ ! -e "$src" ]; then
    echo "error:   $1 not found in $REPO_DIR" >&2
    return 1
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok:      ~/$2 already linked"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$dest.bak"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    fi
    echo "backup:  ~/$2 -> ${backup#"$HOME"/}"
    run mv "$dest" "$backup"
  fi

  run mkdir -p "$(dirname "$dest")"
  echo "link:    ~/$2 -> $src"
  run ln -s "$src" "$dest"
}

status=0
for entry in "${LINKS[@]}"; do
  link "${entry%%:*}" "${entry#*:}" || status=1
done

# Soft dependency check (nothing here is installed automatically)
for cmd in zsh git starship zoxide; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "warning: '$cmd' not found in PATH (see README prerequisites)" >&2
  fi
done

if [ "$status" -eq 0 ]; then
  echo
  echo "Done. Open a new terminal or run: exec zsh"
fi
exit "$status"
