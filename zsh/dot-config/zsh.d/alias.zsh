alias alais='alias'
alias ag='alias | grep'
alias vim='nvim'
alias vi='nvim'

if command -v eza >/dev/null 2>&1; then
    # eza aliases
    alias eza='eza --git --icons --color=auto --classify=auto --color-scale=all'
    alias ls='eza'
    alias lt='eza -la -T'
    alias ll='eza -A'
    alias la='eza -a'
    alias l1='eza -1'
    alias lo='eza -l@'
    alias l='eza -la'
    alias t='eza -T'
else
    # Fallback standard ls aliases
    alias ls='ls --color=auto -F'
    alias ll='ls -A'
    alias la='ls -a'
    alias l1='ls -1'
    alias l='ls -al'
fi

# Search shortcut (works for both eza and standard ls)
alias lg='la | grep'

alias md='mkdir -p'
alias rd='rmdir'

if [ -n "$ZSH_VERSION" ]; then
    alias cp='nocorrect cp'
    alias mv='nocorrect mv'
    alias rm='nocorrect rm'
fi

alias _='sudo ' # space is for recursive alias expnasion
alias please='sudo ' # space is for recursive alias expnasion
alias cpr='cp -r'
alias cps='_ cp -r'
alias rms='_ rm -r'
alias mvs='_ mv'
alias vis='_ vim'

case "$OSTYPE" in
    darwin*)
        alias bi='brew install'
        alias br='brew remove'
        alias bd='brew doctor'
        alias bc='brew cleanup --prune=all'
        ;;

    linux*)
        if [[ -r /etc/os-release ]]; then
            # Read os-release in a subshell so its variables (NAME, ID, etc.) don't pollute your shell
            distro_id=$(. /etc/os-release && echo "$ID $ID_LIKE")
        fi

        case "$distro_id" in
            *ubuntu*|*debian*)
                alias apti='_ apt install'
                alias aptu='_ apt update'
                alias aptr='_ apt remove'
                alias apta='_ apt autoremove'
                alias aptp='_ apt purge'
                ;;

            *arch*|*garuda*)
                alias paci='_ pacman -S'
                alias pacu='_ pacman -Syu'
                alias pacr='_ pacman -Rns'
                alias pacs='pacman -Ss'
                alias pacq='pacman -Qs'
                alias pacc='_ pacman -Sc'
                # Remove orphaned packages (equivalent to apt autoremove)
                alias paca='pacman -Qtdq | _ pacman -Rns -'
                ;;
        esac
        unset distro_id
        ;;
esac

alias h='history'
alias grep='grep -E'
alias df='df -h'
alias du='du -h'
alias cal='cal -m' # calendar shows month

alias tm='tmux'
alias tma='tm att -t'
alias tmaa='tm att -t 0'
alias psa='ps afux'
alias psg='ps aux | grep'

alias fp='ffprobe'
alias dv='yt-dlp'

if [ -n "$ZSH_VERSION" ]; then
    alias mmv='noglob zmv -W' # `mmv *.jpg *.jpeg`, while zmv is `zmv '(*) - (*).png' '$2 - $1.png'`

    alias -g F='--filter'
    alias -g T='--testdox'
    alias -g M='|more'
    alias -g L='|less'
    alias -g H='|head'
    alias -g T='|tail'
    alias -g N='2>/dev/null'
    alias -g G='|grep'
    alias -g GI='|grep -i'
    alias -g GN='|grep -n'
    alias -g S='|sort'
    alias -g SU='|sort -u'
    alias -g C='|pbcopy' # copy to clipboard

    alias -g KU='| iconv -c -f koi8r -t utf8'
    alias -g CU='| iconv -c -f cp1251 -t utf8'
    alias -g UK='| iconv -c -f utf8 -t koi8r'
    alias -g UC='| iconv -c -f utf8 -t cp1251'

    alias -s yaml='bat --language=yaml'
    alias -s toml='bat --language=toml'
    alias -s json='jless'
    alias -s md='glow'
    alias -s mp4='open'
    alias -s mkv='open'
    alias -s png='open'
    alias -s jpg='open'
    alias -s jpeg='open'
    alias -s webp='open'
    alias -s avif='open'
fi

#
if [[ "$OSTYPE" == linux* ]]; then
    if (( $+commands[wl-paste] )); then
        alias pbpaste='wl-paste'
    elif (( $+commands[xclip] )); then
        alias pbpaste='xclip -o -selection clipboard'
    fi
fi

# Global python environment
alias venv='source $PYTHON_DEFAULT_VENV/bin/activate'

# Open Sublime Text
if [[ -x "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]]; then
    subl() {
        "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "$@"
    }
fi

# Change dir and list
cl() {
    cd "$@" && l
}
