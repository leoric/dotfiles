# zsh config

Personal zsh setup built around [Antidote](https://github.com/mattmc3/antidote) (plugin manager) and [Starship](https://starship.rs) (prompt), with aliases and helper functions split into small files under `includes/`.

Works on macOS and Linux. Some helpers are macOS-only (see [Platform notes](#platform-notes)).

## What's in the repo

| Repo file | Installed as | Purpose |
|---|---|---|
| `zshrc-antidote` | `~/.zshrc` | Main interactive config: includes, Antidote, completion, history, keybindings, fzf |
| `zprofile` | `~/.zprofile` | Login-shell env: Homebrew, locale, history size, pager, `PATH`, `LS_COLORS` |
| `antidote-plugins.txt` | `~/.zsh_plugins.txt` | Plugin list that Antidote bundles |
| `includes/` | `~/.zsh_includes` | Aliases and functions, sourced automatically |
| `starship.toml` | `~/.config/starship.toml` | Prompt config, ported from the old Powerlevel10k setup |
| `tmux.conf` | `~/.tmux.conf` | Optional tmux config (Solarized colours), `install.sh --tmux` |
| `nvimrc` | `~/.config/nvim/init.vim` | Optional Neovim config, `install.sh --nvim` |
| `install.sh` | n/a | Creates the symlinks above |

> The names differ on purpose: `zshrc-antidote` and `antidote-plugins.txt` are not hidden files in the repo, but zsh expects `~/.zshrc` and the config expects `~/.zsh_plugins.txt`. `install.sh` handles the renaming.

## Installation

### 1. Prerequisites

Required:

- `zsh` (set as your login shell: `chsh -s "$(command -v zsh)"`)
- `git` (used to auto-install Antidote)
- [`zoxide`](https://github.com/ajeetdsouza/zoxide). `.zshrc` runs `zoxide init` unconditionally, so shell startup prints an error without it.
- [`starship`](https://starship.rs) for the prompt. If it is missing, `.zshrc` skips it and you get the plain zsh prompt.

Recommended (everything degrades gracefully unless noted):

- [Homebrew](https://brew.sh): `zprofile` and several aliases (`bi`, `br`, `bd`, `bc`) assume it
- `eza` for `ls`/`ll`/`la`/`lt` aliases (falls back to plain `ls`)
- `nvim` (`vim` and `vi` are aliased to it)
- `fzf` and `ag` (the silver searcher), used by the fzf block and `fshow`
- `vivid` for `LS_COLORS` (only used when no eza theme exists)
- `keychain` for SSH agent handling
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal, so Starship and eza icons render

macOS:

```sh
brew install zsh git zoxide starship eza neovim fzf the_silver_searcher vivid keychain
```

Debian/Ubuntu:

```sh
sudo apt install zsh git fzf silversearcher-ag keychain neovim
# starship, zoxide, eza and vivid: install from their own releases or your preferred package source
# (starship: curl -sS https://starship.rs/install.sh | sh)
```

### 2. Clone the repo

Clone it somewhere permanent. The symlinks point into this directory, so don't move it afterwards.

```sh
git clone <your-repo-url> ~/zsh
cd ~/zsh
```

The examples below use `~/zsh`. Adjust if you cloned elsewhere.

### 3. Run the installer

```sh
./install.sh
```

This symlinks the files from the table above into your home directory:

```
~/.zshrc           -> ~/zsh/zshrc-antidote
~/.zprofile        -> ~/zsh/zprofile
~/.zsh_plugins.txt -> ~/zsh/antidote-plugins.txt
~/.zsh_includes    -> ~/zsh/includes
~/.config/starship.toml -> ~/zsh/starship.toml
```

- Existing files are moved to `<name>.bak` first (`<name>.bak.<timestamp>` if a `.bak` already exists), so nothing is lost.
- It is safe to run again. Links that already point into the repo are left untouched.
- `./install.sh --tmux` and `./install.sh --nvim` also link `tmux.conf` and `nvimrc`.
- `./install.sh --dry-run` prints what would happen without changing anything.
- The prompt config is shared across machines, so it is tracked and linked like everything else. Edit `starship.toml` in the repo.
- It warns about missing `zsh`, `git`, `starship` and `zoxide`, but does not install them.

Verify:

```sh
ls -l ~/.zshrc ~/.zprofile ~/.zsh_plugins.txt ~/.zsh_includes ~/.config/starship.toml
```

Each should show `->` pointing into `~/zsh`.

#### Symlinking includes: whole directory vs. per file

`install.sh` links the **entire `includes/` directory** as `~/.zsh_includes`. This is the simplest option, and new files you add to the repo are picked up automatically.

If you only want some of the includes on a given machine (for example, skip `factorio.zsh` and `avif.zsh` on a server), run `install.sh` first, then replace the `~/.zsh_includes` link with a real directory containing links to just the files you want:

```sh
rm ~/.zsh_includes && mkdir ~/.zsh_includes
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

### 4. Install Antidote and the plugins

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

### 5. The prompt

`starship.toml` reproduces the previous Powerlevel10k look (classic style, two lines, sharp powerline arrows, dotted gap) and is linked to `~/.config/starship.toml` by `install.sh`. It needs a Nerd Font in the terminal.

```
 ◀  ▶ ~/dev/repo/src ▶  main !2 ?1 ▶ ·················· ◀ ✘ INT ◀ 3s ◀ .venv ◀ 12:34:56 ▶
❯
```

- **Left:** OS icon, directory (parents dimmed, repo root bold, deep paths shortened), git branch with `⇣⇡` ahead/behind, `*` stash, `~` conflicts, `+` staged, `!` unstaged, `?` untracked.
- **Right:** signal or pipeline failure, command duration (3s and up), background jobs, direnv, Python virtualenv, conda, nix-shell, kubernetes, terraform, aws, `user@host` (SSH or root only), time.
- **Prompt character:** `❯` green, red after a failed command, `❮`/`V`/`▶` for vi modes.

Colours are the same 256-colour numbers as the old config. See the comments in `starship.toml` for the glyph legend.

To change something, edit `starship.toml` and open a new prompt (Starship reads it on every render). Docs: <https://starship.rs/config/>. For a machine-specific override, point `STARSHIP_CONFIG` at another file (exported before the prompt is initialised) instead of editing the shared one.

#### Differences from Powerlevel10k

Starship cannot do some things p10k did:

- **Git colour.** p10k turned the git segment from green to yellow when the repo had tracked changes. Starship cannot recolour a segment by state, so it stays green and the markers carry the information. Push-remote markers (`⇠⇢`), the `wip` marker and the remote branch name are not shown either.
- **Right-side arrows.** Each right segment draws its own `◀` head, so neighbours are not fused into one continuous chain as in p10k.
- **Plain failures.** A non-zero exit only turns the `❯` red, as before. Signals and failed pipelines also get a segment.
- **Show-on-command segments.** p10k showed kubernetes, aws, terraform, azure and gcloud only while you typed the matching command. Starship has no such trigger: kubernetes appears in directories with `Chart.yaml`, `kustomization.yaml`, etc., terraform in `*.tf` directories, aws when credentials are configured. azure, gcloud, aws elastic beanstalk and google app credentials are not included.
- **Version managers.** asdf, pyenv, nvm, nodenv, rbenv and friends have no Starship equivalent. Language modules show the active tool version instead. They are not in the prompt; to add one, put it in `format` and (optionally) restyle it in the same way as the others, e.g. for Node:

  ```toml
  # in `format`, before $time:  $nodejs\
  [nodejs]
  format = "[\ue0b2](fg:2)[ $symbol$version ](fg:0 bg:2)"
  ```
- **Dropped.** Instant prompt and transient prompt (both off or quiet in the old config), todo, timewarrior, taskwarrior, nordvpn, ranger, yazi, nnn, lf, xplr, vim shell, midnight commander, chezmoi shell, toolbox and per-directory-history.
- **Duration format** is Starship's (`2m5s`), not `2m 5s`.

#### Migrating from Powerlevel10k

The `romkatv/powerlevel10k` plugin and the `~/.p10k.zsh` hook are gone from the repo. Your old `~/.p10k.zsh` was the source for `starship.toml` and is no longer read. After pulling, run `./install.sh` again so `~/.config/starship.toml` is linked (an existing file there is backed up to `starship.toml.bak`), then rebuild the plugin bundle and clean up the leftovers:

```sh
rm -f ~/.zsh_plugins.zsh ~/.p10k.zsh ~/.cache/p10k-*
exec zsh
```

Antidote's local clone of the plugin can be removed with `antidote purge romkatv/powerlevel10k`.

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
| `python.zsh` | `py` (auto-activates `~/.venv`), `python3 -m pip install` fallback to brew, then pipx |
| `ffmpeg.zsh` | `fcrop`, `ff1`, `fb` and other ffmpeg helpers |
| `webp.zsh`, `avif.zsh` | Image conversion helpers (`wp`, `wpr`, `av`) |
| `factorio.zsh` | Factorio mod tagging/deploy helpers |
| `nocorrect.zsh` | `CORRECT_IGNORE_FILE` for `setopt correctall` |

## Things to review before using

- **LLM variables in `.zshrc`.** The top of `zshrc-antidote` exports `GEMINI_MODEL`, `ANTHROPIC_MODEL` and `ANTHROPIC_BASE_URL` (pointing at a third-party router). Change or delete these if you don't use that endpoint.
- **Project paths in `zprofile`.** `PRO_PROJECT_ROOT=$HOME/pro` and `PYTHON_DEFAULT_VENV=$HOME/.venv` drive the automatic virtualenv switching (`manage_pro_venv`, run on every `cd`). Create the venv with `python3 -m venv ~/.venv`, or change the paths.
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
rm ~/.zshrc ~/.zprofile ~/.zsh_plugins.txt ~/.zsh_includes ~/.config/starship.toml ~/.tmux.conf ~/.config/nvim/init.vim
rm -rf ~/.antidote ~/.zsh_plugins.zsh
# restore backups if you made them
for f in ~/.zshrc.bak ~/.zprofile.bak; do [ -e "$f" ] && mv "$f" "${f%.bak}"; done
```

## Troubleshooting

- **`zoxide: command not found` on startup.** Install zoxide, or comment out the `eval "$(zoxide init zsh)"` line.
- **Aliases/functions missing.** Check `ls -l ~/.zsh_includes`: the link must exist and not be broken, and filenames must end in `sh`.
- **Plugins not loading after editing the list.** Make sure `~/.zsh_plugins.txt` is a working symlink; if not, delete `~/.zsh_plugins.zsh` and run `exec zsh`.
- **Broken icons in prompt or `ls`.** Set a Nerd Font in your terminal profile.
- **Arrows or icons show as boxes.** The prompt uses powerline and Nerd Font glyphs; set a Nerd Font in the terminal profile.
- **Plain prompt, no Starship.** Check `command -v starship`; `.zshrc` silently skips it when the binary is missing.
- **`install.sh` reports a backup.** That is expected: your previous file was moved to `<name>.bak` in `~`.
- **Slow first start.** Antidote is cloning all plugins; later starts use the cached `~/.zsh_plugins.zsh`.
