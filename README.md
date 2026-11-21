# zsh config

Personal zsh setup built around [Antidote](https://github.com/mattmc3/antidote) (plugin manager) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (prompt), with aliases and helper functions split into small files under `includes/`.

Works on macOS and Linux. Some helpers are macOS-only (see [Platform notes](#platform-notes)).

## What's in the repo

| Repo file | Installed as | Purpose |
|---|---|---|
| `zshrc-antidote` | `~/.zshrc` | Main interactive config: includes, Antidote, completion, history, keybindings, fzf |
| `zprofile` | `~/.zprofile` | Login-shell env: Homebrew, locale, history size, pager, `PATH`, `LS_COLORS` |
| `antidote-plugins.txt` | `~/.zsh_plugins.txt` | Plugin list that Antidote bundles |
| `includes/` | `~/.zsh_includes` | Aliases and functions, sourced automatically |
| `tmux.conf` | `~/.tmux.conf` | Optional tmux config (Solarized colours) |

> The names differ on purpose: `zshrc-antidote` and `antidote-plugins.txt` are not hidden files in the repo, but zsh expects `~/.zshrc` and the config expects `~/.zsh_plugins.txt`. The symlinks below handle the renaming.

## Installation

### 1. Prerequisites

Required:

- `zsh` (set as your login shell: `chsh -s "$(command -v zsh)"`)
- `git` (used to auto-install Antidote)
- [`zoxide`](https://github.com/ajeetdsouza/zoxide). `.zshrc` runs `zoxide init` unconditionally, so shell startup prints an error without it.

Recommended (everything degrades gracefully unless noted):

- [Homebrew](https://brew.sh): `zprofile` and several aliases (`bi`, `br`, `bd`, `bc`) assume it
- `eza` for `ls`/`ll`/`la`/`lt` aliases (falls back to plain `ls`)
- `nvim` (`vim` and `vi` are aliased to it)
- `fzf` and `ag` (the silver searcher), used by the fzf block and `fshow`
- `vivid` for `LS_COLORS` (only used when no eza theme exists)
- `keychain` for SSH agent handling
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal, so Powerlevel10k and eza icons render

macOS:

```sh
brew install zsh git zoxide eza neovim fzf the_silver_searcher vivid keychain
```

Debian/Ubuntu:

```sh
sudo apt install zsh git fzf silversearcher-ag keychain neovim
# zoxide, eza and vivid: install from their own releases or your preferred package source
```

### 2. Clone the repo

Clone it somewhere permanent. The symlinks point into this directory, so don't move it afterwards.

```sh
git clone <your-repo-url> ~/zsh
cd ~/zsh
```

The examples below use `~/zsh`. Adjust if you cloned elsewhere.

### 3. Back up existing files

`ln -s` will not overwrite existing files, so move them out of the way first:

```sh
for f in .zshrc .zprofile .zsh_plugins.txt .zsh_includes .tmux.conf; do
  [ -e ~/"$f" ] || [ -L ~/"$f" ] && mv ~/"$f" ~/"$f".bak
done
```

(`*.bak` is already in `.gitignore`.)

### 4. Create the symlinks

```sh
ln -s ~/zsh/zshrc-antidote      ~/.zshrc
ln -s ~/zsh/zprofile            ~/.zprofile
ln -s ~/zsh/antidote-plugins.txt ~/.zsh_plugins.txt
ln -s ~/zsh/includes            ~/.zsh_includes
ln -s ~/zsh/tmux.conf           ~/.tmux.conf   # optional
```

Verify:

```sh
ls -l ~/.zshrc ~/.zprofile ~/.zsh_plugins.txt ~/.zsh_includes
```

Each should show `->` pointing into `~/zsh`.

#### Symlinking includes: whole directory vs. per file

The command above links the **entire `includes/` directory** as `~/.zsh_includes`. This is the simplest option, and new files you add to the repo are picked up automatically.

If you only want some of the includes on a given machine (for example, skip `factorio.zsh` and `avif.zsh` on a server), create a real directory and link just the files you want:

```sh
mkdir -p ~/.zsh_includes
cd ~/zsh/includes
for f in alias.zsh functions.zsh git.bash docker.bash python.zsh nocorrect.zsh; do
  ln -sf "$PWD/$f" ~/.zsh_includes/"$f"
done
```

How includes are loaded (from `.zshrc`):

```zsh
for file in $HOME/.zsh_includes/*.*sh; do
  [ -f "$file" ] && source "$file"
done
```

- Both `.zsh` and `.bash` files are sourced (glob `*.*sh`), in alphabetical order.
- Symlinks are followed, so linked files work normally.
- Anything not ending in `sh` is ignored (e.g. the editor undo file `.alias.zsh.un~`).
- The includes are sourced **before** Antidote loads. This matters: `is_supported_os` (defined in `functions.zsh`) is used by the `conditional:is_supported_os` rule in the plugin list. Don't remove `functions.zsh` or reorder the blocks without accounting for that.

### 5. Install Antidote and the plugins

Nothing to do manually. On first launch, `.zshrc` will:

1. Clone Antidote to `~/.antidote` if it isn't there.
2. Generate `~/.zsh_plugins.zsh` from `~/.zsh_plugins.txt` (this clones every plugin on the first run, so the first start is slow).
3. Source the generated file.

Just open a new terminal:

```sh
exec zsh
```

To install Antidote ahead of time instead:

```sh
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

### 6. Configure the prompt

On first start Powerlevel10k will launch its configuration wizard. If it doesn't, run:

```sh
p10k configure
```

This writes `~/.p10k.zsh`, which `.zshrc` sources automatically. It is machine-specific and not tracked in this repo.

## Day-to-day usage

**Add or remove a plugin:** edit `antidote-plugins.txt` (it is `~/.zsh_plugins.txt` through the symlink) and open a new shell. `.zshrc` regenerates `~/.zsh_plugins.zsh` whenever the `.txt` file is newer.

**Update plugins:**

```sh
antidote update
```

**Force a plugin rebuild:**

```sh
rm ~/.zsh_plugins.zsh && exec zsh
```

**Add a new alias/function file:** drop it into `includes/` with a `.zsh` or `.bash` extension. With the directory symlink it is sourced in every new shell. With per-file links, add a symlink for it.

**Reload after editing:**

```sh
exec zsh
```

### Plugins

| Plugin | What it does |
|---|---|
| `djui/alias-tips` | Reminds you of an existing alias for the command you ran |
| `hcgraf/zsh-sudo` | Press `Esc Esc` to prefix the command with `sudo` |
| `jreese/zsh-titles` | Terminal/tmux titles from location and task |
| `MichaelAquilina/zsh-auto-notify` | Desktop notifications for long commands (only when `is_supported_os`, i.e. macOS or non-WSL Linux) |
| `romkatv/powerlevel10k` | Prompt theme |
| `yous/vanilli.sh` | Minimal sensible defaults |
| `zlsun/solarized-man` | Coloured man pages |
| `zsh-users/zsh-autosuggestions` | Fish-style suggestions |
| `zsh-users/zsh-completions` | Extra completion definitions |
| `zsh-users/zsh-history-substring-search` | Up/Down arrows search history by substring |
| `zsh-users/zsh-syntax-highlighting` | Command highlighting |

### Includes

| File | Contents |
|---|---|
| `alias.zsh` | General aliases (`ls` via eza, `md`, `rd`, `_`/`please` for sudo, brew and apt shortcuts, ...) |
| `functions.zsh` | `png`, `rmr` (safe recursive delete), `brew` typo wrapper, `is_supported_os`, project venv switching, `vibe_advance`, and more |
| `git.bash` | Git aliases (`gst`-style shortcuts, `gds` for `git diff --staged`, ...) |
| `docker.bash` | `d`, `dc` (picks the compose file by OS), `dcu`, `dcd`, `dce`, ... |
| `composer.bash` | PHP/Symfony shortcuts (`co`, `ci`, `cr`, `c`, `u`, ...) |
| `python.zsh` | `py` (auto-activates `~/py.env`), `python3 -m pip install` fallback to brew, then pipx |
| `ffmpeg.zsh` | `fcrop`, `ff1`, `fb` and other ffmpeg helpers |
| `webp.zsh`, `avif.zsh` | Image conversion helpers (`wp`, `wpr`, `av`) |
| `factorio.zsh` | Factorio mod tagging/deploy helpers |
| `nocorrect.zsh` | `CORRECT_IGNORE_FILE` for `setopt correctall` |

## Things to review before using

- **LLM variables in `.zshrc`.** The top of `zshrc-antidote` exports `GEMINI_MODEL`, `ANTHROPIC_MODEL` and `ANTHROPIC_BASE_URL` (pointing at a third-party router). Change or delete these if you don't use that endpoint.
- **Project paths in `zprofile`.** `PRO_PROJECT_ROOT=$HOME/pro` and `PRO_VENV=$HOME/py.env` drive the automatic virtualenv switching (`manage_pro_venv`, run on every `cd`). Create the venv with `python3 -m venv ~/py.env`, or change the paths.
- **`PATH` entries in `zprofile`** (`~/.spoofdpi/bin`, `~/MEGA/IT/bin`) are specific to the original machine. Remove what doesn't exist for you.
- **`keychain`** is called with `id_rsa`. Change the key name if you use e.g. `id_ed25519`.
- **Secrets.** Files matching `*secrets*` are git-ignored. Keep tokens in such a file (and source it from `.zshrc`) rather than committing them.

## Platform notes

- `avif.zsh`, `webp.zsh` need `pbpaste` (macOS). On Linux, alias it to `xclip -o` / `wl-paste` or skip those files.
- `ff1` uses `h264_videotoolbox` (macOS hardware encoder).
- `factorio_deploy` uses `osascript` (macOS).
- `zprofile` only loads Homebrew from `/opt/homebrew` (Apple Silicon). On Intel macOS or Linuxbrew, adjust the path.
- `tmux.conf` uses options removed in tmux 2.1+ (`mode-mouse`, `status-attr`, `*-fg/-bg`). On a modern tmux, replace them with `set -g mouse on` and the `-style` options.

## Uninstall

```sh
rm ~/.zshrc ~/.zprofile ~/.zsh_plugins.txt ~/.zsh_includes ~/.tmux.conf
rm -rf ~/.antidote ~/.zsh_plugins.zsh
# restore backups if you made them
for f in ~/.zshrc.bak ~/.zprofile.bak; do [ -e "$f" ] && mv "$f" "${f%.bak}"; done
```

## Troubleshooting

- **`zoxide: command not found` on startup.** Install zoxide, or comment out the `eval "$(zoxide init zsh)"` line.
- **Aliases/functions missing.** Check `ls -l ~/.zsh_includes`: the link must exist and not be broken, and filenames must end in `sh`.
- **Plugins not loading after editing the list.** Make sure `~/.zsh_plugins.txt` is a working symlink; if not, delete `~/.zsh_plugins.zsh` and run `exec zsh`.
- **Broken icons in prompt or `ls`.** Set a Nerd Font in your terminal profile.
- **Slow first start.** Antidote is cloning all plugins; later starts use the cached `~/.zsh_plugins.zsh`.
