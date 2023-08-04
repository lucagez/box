#!/usr/bin/env zsh

export SHELL=$(which zsh)

##########################
#      Key bindings      #
##########################
autoload -Uz {up,down}-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key
 
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
 
# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-beginning-search
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-beginning-search
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete
 
# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
 
##########################
#         History        #
##########################
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE="10000000"
export SAVEHIST="10000000"
setopt histignore{alldups,space} {append,extended,share}history
 
##########################
#       Completion       #
##########################
# export SHELL=${SHELL:-${HOME}/.nix-profile/bin/zsh}
eval "$(dircolors)"
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
compinit
 
##########################
#         Prompt         #
##########################
if [ ! -d ~/.zsh ]; then
    mkdir -p ~/.zsh
fi

if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi

if [ ! -d ~/.zsh/catppuccin ]; then
    git clone https://github.com/catppuccin/zsh-syntax-highlighting.git ~/.zsh/catppuccin
fi

if [ ! -d ~/powerlevel10k ]; then
    git clone https://github.com/romkatv/powerlevel10k ~/powerlevel10k
    rm -rf ~/powerlevel10k/.git
fi

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/catppuccin/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/powerlevel10k/config/p10k-robbyrussell.zsh
typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='%B📦'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='005'

##########################
#        Aliases         #
##########################
alias ls='ls --color=auto'
alias la='ls --color=auto -A'
alias  l='ls --color=auto -lh --group-directories-first'
alias ll='ls --color=auto -lh --group-directories-first -As'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
 
##########################
#      Miscellaneous     #
##########################
setopt autocd correct noglobdots nohup unset

##########################
#       Variables        #
##########################

# Node
export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"

# Go
export GOROOT=/root/.go
export PATH=$GOROOT/bin:$PATH
export GOPATH=/root/go
export PATH=$GOPATH/bin:$PATH

# Term
export TERM=xterm
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim

function sync_nvim() {
    echo "☁️  syncing nvim plugins"
    nvim --headless "+Lazy! sync" +qa
}

