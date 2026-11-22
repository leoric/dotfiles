alias alais='alias'
alias ag='alias | grep'
alias vim='nvim'
alias vi='nvim'

if command -v eza >/dev/null 2>&1; then
    # eza aliases
    alias eza='eza --git --icons --color=auto --classify=auto --color-scale=all'
    alias ls='eza'
    alias lt='eza --tree'
    alias ll='eza -A'
    alias la='eza -a'
    alias l1='eza -1'
    alias l='eza -la'
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

alias _='sudo'
alias please='sudo'
alias cpr='cp -r'
alias cps='_ cp -r'
alias rms='_ rm -r'
alias mvs='_ mv'
alias vis='_ vim'

alias bi='brew install'
alias br='brew remove'
alias bd='brew doctor'
alias bc='brew cleanup --prune=all'

alias apti='_ apt install'
alias aptu='_ apt update'
alias aptr='_ apt remove'
alias apta='_ apt autoremove'
alias aptp='_ apt purge'

alias h='history'
alias grep='grep -E'
alias cal='cal -m'
alias df='df -h'
alias du='du -h'

alias tm='tmux'
alias tma='tm att -t'
alias tmaa='tm att -t 0'
alias psa='ps afux'
alias psg='ps aux | grep'

alias fp='ffprobe'
alias dv='yt-dlp'
alias commit='commit --timeout 30s'

if [ -n "$ZSH_VERSION" ]; then
    alias zmv='noglob zmv'

    alias -g F='--filter'
    alias -g T='--testdox'
    alias -g C='|ccze'
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

    alias -g KU='| iconv -c -f koi8r -t utf8'
    alias -g CU='| iconv -c -f cp1251 -t utf8'
    alias -g UK='| iconv -c -f utf8 -t koi8r'
    alias -g UC='| iconv -c -f utf8 -t cp1251'
fi

# Global python environment
alias venv='source $PRO_VENV/bin/activate'

# Open Sublime Text
subl() {
    /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl "$@"
}
