# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), separated into per-tool packages (`zsh`, `tmux`, `nvim`). The `zsh` package is built around [Antidote](https://github.com/mattmc3/antidote) (plugin manager) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (prompt), with aliases and helper functions split into small files under `zsh/dot-config/zsh.d/`.

Works on macOS and Linux. Some helpers are macOS-only (see [Platform notes](#platform-notes)).

## What's in the repo

Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) package whose contents mirror `$HOME`. Names starting with `dot-` become `.` when stowed with `stow --dotfiles`.

| Package | Repo path | Stowed target | Purpose |
|---|---|---|---|
| `zsh` | `zsh/dot-zshrc` | `~/.zshrc` | Main interactive config: Antidote, completion, history, keybindings, fzf |
| | `zsh/dot-zprofile` | `~/.zprofile` | Login-shell env: Homebrew, locale, pager, path, colors, secrets |
| | `zsh/dot-config/zsh.d/` | `~/.config/zsh.d/` | Aliases and functions, sourced automatically |
| | | | |
| | `zsh/dot-config/zsh.d/antidote-plugins.txt` | `~/.config/zsh.d/antidote-plugins.txt` | Plugin list that Antidote bundles |
| | | | |
| | `zsh/dot-config/p10k/` | `~/.config/p10k/` | Powerlevel10k config (`p10k.zsh`) and theme (`p10k-theme.zsh`) |
| | | | |
| `tmux` | `tmux/dot-tmux.conf` | `~/.tmux.conf` | Optional tmux config (Solarized colours) |
| | | | |
| `nvim` | `nvim/dot-config/nvim/init.vim` | `~/.config/nvim/init.vim` | Optional Neovim config |

## Installation

### 1. Prerequisites

Required:

- [`stow`](https://www.gnu.org/software/stow/) 2.3.1 or newer (needed for `--dotfiles`)
- `zsh` (set as your login shell: `chsh -s "$(command -v zsh)"`)
- `git` (used to auto-install Antidote)
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) (`zsh/dot-zshrc` runs `zoxide init` unconditionally, so shell startup prints an error without it)

Recommended (everything degrades gracefully unless noted):

- [Homebrew](https://brew.sh): `zsh/dot-zprofile` and several aliases (`bi`, `br`, `bd`, `bc`) assume it
- `eza` for `ls`/`ll`/`la`/`lt` aliases (falls back to plain `ls`)
- `nvim` (`vim` and `vi` are aliased to it)
- `fzf` and `ag` (the silver searcher), used by the fzf block and `fshow`
- `vivid` for `LS_COLORS` (only used when no eza theme exists)
- `keychain` for SSH agent handling
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal, so Powerlevel10k and eza icons render

macOS:

```sh
brew install stow zsh git zoxide eza neovim fzf the_silver_searcher vivid keychain
