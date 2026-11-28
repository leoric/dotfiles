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
- package manager like [Homebrew](https://brew.sh), apt or pacman

Recommended (everything degrades gracefully unless noted):

- `eza` for `ls`/`ll`/`la`/`lt` aliases (falls back to plain `ls`)
- `nvim` (`vim` and `vi` are aliased to it)
- `fzf` for fuzzy search of files and arguments and Git commit history browser (`glf`)
- `vivid` for `LS_COLORS` (only used when no eza theme exists)
- `keychain` for SSH agent handling (CLI wrapper around `ssh-agent`—not to be confused with the macOS Keychain app, though it can integrate with it)
- [`carapace`](https://carapace-sh.github.io/carapace-bin/install.html) for multi-shell argument completions
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal, so Powerlevel10k and eza icons render

macOS:

```sh
brew install stow zsh git zoxide eza neovim fzf ripgrep vivid keychain carapace
```

Arch / Garuda:

```sh
sudo pacman -S stow zsh git zoxide eza neovim fzf ripgrep vivid keychain
# carapace: install from the AUR (e.g. paru -S carapace-bin) or see https://carapace-sh.github.io/carapace-bin/install.html
```

Debian/Ubuntu:

```sh
sudo apt install stow zsh git fzf ripgrep neovim keychain
# zoxide, eza, vivid, and carapace: install from their own releases or package repositories
# carapace install guide: https://carapace-sh.github.io/carapace-bin/install.html
```

### 2. Clone the repo

Clone it somewhere permanent. Stow creates symlinks that point into this directory, so don't move it afterwards.

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

The examples below use `~/dotfiles`. Adjust if you cloned elsewhere.

### 3. Stow the packages

Always pass the target explicitly (`-t "$HOME"`), because Stow's default target is the *parent* of the current directory.

```sh
stow --dotfiles -t "$HOME" zsh
```

Optional packages:

```sh
stow --dotfiles -t "$HOME" tmux nvim
```

Or everything at once:

```sh
stow --dotfiles -t "$HOME" */
```

Useful flags:

- `-n -v` (dry run, verbose) shows what would be linked without touching anything.
- `-D` unstows a package: `stow --dotfiles -D -t "$HOME" tmux`.
- `-R` restows after you add or rename files in a package.

Stow refuses to overwrite existing files. If it reports a conflict, move the old file away first (for example `mv ~/.zshrc ~/.zshrc.bak`) and run it again.

Verify:

```sh
ls -l ~/.zshrc ~/.zprofile ~/.config/zsh.d ~/.config/p10k
```

Each should show `->` pointing into `~/dotfiles/zsh/...`. Where `~/.config/zsh.d` or `~/.config/p10k` didn't exist beforehand, Stow links the whole directory; otherwise it links the files inside.

#### `zsh.d`: all files vs. a selection

`.config/zsh.d/` is linked as a folder by default, so new files you add to the repo are picked up automatically.

If you only want some snippets on a given machine (for example, skip `factorio.zsh` and `avif.zsh` on a server), stow with `--no-folding` so `~/.config/zsh.d/` is a real directory containing one symlink per file, then delete the links you don't want:

```sh
stow --dotfiles --no-folding -t "$HOME" zsh
rm ~/.config/zsh.d/{factorio,avif}.zsh
```

Running `stow --dotfiles --no-folding -R -t "$HOME" zsh` again recreates them, so repeat the `rm` afterwards.

How snippets are loaded (from `.zshrc`):

```zsh
for file in $HOME/.config/zsh.d/*.*sh; do
  [ -f "$file" ] && source "$file"
done
```

- Both `.zsh` and `.bash` files are sourced (glob `*.*sh`), in alphabetical order.
- Symlinks are followed, so linked files work normally.
- Anything not ending in `sh` is ignored (e.g. editor undo files like `.alias.zsh.un~`).
- The snippets are sourced **after** the plugins are loaded.
- `_is_supported_os` is defined near the top of `.zshrc`, not in a snippet, because the `conditional:_is_supported_os` rule in `antidote-plugins.txt` needs it when Antidote bundles the plugins.

### 4. Install Antidote and the plugins

Nothing to do manually. On first launch, `~/.zshrc` will:

1. Clone Antidote to `~/.antidote` if it isn't there.
2. Generate `~/.cache/antidote-plugins.zsh` from `~/.config/zsh.d/antidote-plugins.txt` (this clones every plugin on the first run, so the first start is slow). The generated file lives in the cache directory on purpose, so it doesn't end up inside the repo.
3. Source the generated file.

Just open a new terminal:

```sh
exec zsh
```

To install Antidote ahead of time instead:

```sh
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

### 5. The prompt

On first start Powerlevel10k will launch its configuration wizard. If it doesn't, run:

```sh
p10k configure
```

`p10k configure` rewrites `~/.config/p10k/p10k.zsh`, which `~/.zshrc` sources automatically. That file is a symlink to `zsh/dot-config/p10k/p10k.zsh` in the repo, so the new settings show up in `git diff`. `p10k-theme.zsh` in the same directory is sourced afterwards and applies the light/dark colour adjustments.

## Day-to-day usage

**Add or remove a plugin:** edit `zsh/dot-config/zsh.d/antidote-plugins.txt` (symlinked to `~/.config/zsh.d/antidote-plugins.txt`) and open a new shell. `~/.zshrc` regenerates `~/.cache/antidote-plugins.zsh` whenever the `.txt` file is newer.

**Update plugins:**

```sh
antidote update
```

**Force a plugin rebuild:**

```sh
rm ~/.cache/antidote-plugins.zsh && exec zsh
```

**Add a new alias/function file:** drop it into `zsh/dot-config/zsh.d/` with a `.zsh` or `.bash` extension. If `~/.config/zsh.d` is a folded symlink it is sourced in every new shell right away; if you stowed with `--no-folding`, run `stow --dotfiles --no-folding -R -t "$HOME" zsh` to link the new file.

**Reload after editing:**

```sh
exec zsh
```

### Plugins

| Plugin | What it does |
|---|---|
| `djui/alias-tips` | Reminds you of an existing alias for the command you ran |
| `jreese/zsh-titles` | Terminal/tmux titles from location and task |
| `MichaelAquilina/zsh-auto-notify` | Desktop notifications for long commands |
| `romkatv/powerlevel10k` | Prompt theme |
| `zsh-users/zsh-autosuggestions` | Fish-style suggestions |
| `zsh-users/zsh-completions` | Extra completion definitions |
| `zsh-users/zsh-history-substring-search` | Up/Down arrows search history by substring |
| `zsh-users/zsh-syntax-highlighting` | Command highlighting |

### zsh.d

| File | Contents |
|---|---|
| `antidote-plugins.txt` | **Not a snippet** Contains plugins loaded via Antitode |
| `alias.zsh` | General aliases (`ls` via eza, `md`, `rd`, `_`/`please` for sudo, brew and apt shortcuts, ...) |
| `functions.zsh` | `png`, `rmr` (safe recursive delete), `brew` typo wrapper, project venv switching, `vibe_advance`, and more |
| `git.bash` | Git aliases (`gst`-style shortcuts, `gds` for `git diff --staged`, ...) |
| `docker.bash` | `d`, `dc` (picks the compose file by OS), `dcu`, `dcd`, `dce`, ... |
| `composer.bash` | PHP/Symfony shortcuts (`co`, `ci`, `cr`, `c`, `u`, ...) |
| `python.zsh` | `py` (auto-activates `~/.venv`), `python3 -m pip install` fallback to brew, then pipx |
| `llm.bash` | LLM environment variables and helpers |
| `ffmpeg.zsh` | `fcrop`, `ff1`, `fb` and other ffmpeg helpers |
| `webp.zsh`, `avif.zsh` | Image conversion helpers (`wp`, `wpr`, `av`) |
| `factorio.zsh` | Factorio mod tagging/deploy helpers |

## Things to review before using

- **LLM variables in `.config/zsh.d/llm.bash`.** Change or delete these if you don't use that endpoint.
- **Project paths in `.zprofile`.** `PRO_PROJECT_ROOT=$HOME/pro` and `PYTHON_DEFAULT_VENV=$HOME/.venv` drive the automatic virtualenv switching (`manage_pro_venv`, run on every `cd`). Create the venv with `python3 -m venv ~/.venv`, or change the paths.
- **`PATH` entries in `.zprofile`** (`~/.spoofdpi/bin`, `~/MEGA/IT/bin`) are specific to the original machine. Remove what doesn't exist for you.
- **`keychain`** is called with `id_rsa`. Change the key name if you use e.g. `id_ed25519`.
- **Secrets.** Files matching `*secrets*` are git-ignored. Keep tokens in such a file (and source it from `.zshrc`) rather than committing them.

## Platform notes

- `avif.zsh`, `webp.zsh` need `pbpaste` (macOS). On Linux, alias it to `xclip -o` / `wl-paste` or skip those files.
- `factorio_deploy` uses `osascript` (macOS).
- `.zprofile` only loads Homebrew from `/opt/homebrew` (Apple Silicon). On Intel macOS or Linuxbrew, adjust the path.
- `dot-tmux.conf` uses options removed in tmux 2.1+ (`mode-mouse`, `status-attr`, `*-fg/-bg`). On a modern tmux, replace them with `set -g mouse on` and the `-style` options.

## Uninstall

```sh
cd ~/dotfiles
stow --dotfiles -D -t "$HOME" zsh tmux nvim
rm -rf ~/.antidote ~/.cache/antidote-plugins.zsh
```

Stow only removes the symlinks it created. Restore any files you moved aside before stowing.

## Troubleshooting

- **`zoxide: command not found` on startup.** Install zoxide, or comment out the `eval "$(zoxide init zsh)"` line.
- **Aliases/functions missing.** Check `ls -l ~/.config/zsh.d`: the link must exist and not be broken, and filenames must end in `sh`.
- **Plugins not loading after editing the list.** Make sure `~/.config/zsh.d/antidote-plugins.txt` is a working symlink to `zsh/dot-config/zsh.d/antidote-plugins.txt`; if so, delete `~/.cache/antidote-plugins.zsh` and run `exec zsh`.
- **Broken icons, arrows, or boxes in prompt or `ls`.** Powerlevel10k and `eza` use Powerline and Nerd Font glyphs; set a Nerd Font in your terminal profile.
- **Stow reports a conflict ("existing target is not owned by stow").** A real file or an old symlink is in the way. Move or remove it and run `stow` again.
- **Slow first start.** Antidote is cloning all plugins; later starts use the cached `~/.cache/antidote-plugins.zsh`.