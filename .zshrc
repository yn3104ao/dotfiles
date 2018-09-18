# Set up the prompt
PROMPT='%n@%m>'
autoload -U promptinit; promptinit

#optionally define some options
PURE_PROMPT_SYMBOL=\ %B\➤

#LANG
export LANG=en_US.UTF-8

#no beep sound when complete list displayed
setopt nolistbeep

#cdとlsの省略
setopt auto_cd
function chpwd() { ls -aFX }

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt hist_ignore_dups
setopt share_history
setopt auto_pushd
setopt pushd_ignore_dups

# Use modern completion system
autoload -Uz compinit
compinit
setopt correct

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
# Source Prezto. 
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
	source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
#Customize to your needs... 
#shellの再起動エイリアス
alias rs='exec $SHELL -l' 

# lsのエイリアス 
alias ls='ls --show-control-chars -aFX --color=auto'
alias la='ls -A' 
alias lg='ls -Agh'
alias ll='ls -Ahl'

# 隠しファイルのみ表示
alias ld='ls -dh .*'
alias lld='ls -ldh .*'  

# 確認 
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i' 

# 省略
alias v=vim
alias e=echo
alias th=touch 

# sudo の後のコマンドでエイリアスを有効にするらしい
alias sudo='sudo ' 

# クリップボードにコピペ
alias co='xsel --clipboad --input'
alias -g C='xsel --clipboad --input' #グローバルにコピー


alias pa='xsel --clipboad --output'
alias -g P='xsel --clipboad --output' #グローバルにペースト

# 出力からgrep
alias -g G='| grep'

# 設定ファイルをどっからでもすぐ開く
alias -g zrc='~/.zshrc'
alias -g vrc='~/.vimrc'
alias -g gvrc='~/.gvimrc' 

# git関連お好みで
alias g=git 
alias gad='git add' 
alias gau='git add -u' 
alias gaa='git add -A' 
alias gc='git commit -m' 
alias gl='git log --oneline' 
alias gs='git status -sb'

# 設定即反映
alias sz='source ~/.zshrc' #これもクソ便利です

# Preztoアップデート 
alias preup='cd ~/.zprezto && git pull && git submodule update --init --recursive ; cd -'

#tmux
function tm() {
       if [ -n "${1}" ]; then
          tmux attach-session -t ${1} || \
          tmux new-session -s ${1}
    else
          tmux attach-session || \
          tmux new-session
       fi
}
