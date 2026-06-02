#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
 # ow=37;42 sets "Other-Writable" to White text (37) on Green background (42)
export LS_COLORS=$LS_COLORS:"ow=37;42:"

# Source the system-wide bashrc if it exists
[[ -f /etc/bash.bashrc ]] && . /etc/bash.bashrc

# Example: Adding an Arch icon (if using a Nerd Font)
# The code \uF303 is the Nerd Font hex for the Arch logo
#export PS1="\[\033[01;36m\]\uF303 [\u@\h \W]\[\033[01;37m\]\$ \[\033[00m\]"

eval "$(starship init bash)"

# Created by `pipx` on 2026-04-05 01:33:20
export PATH="$PATH:$HOME/.local/bin"
export VISUAL="nvim"
export EDITOR="nvim"
export SUDO_EDITOR="nvim"xport SUDO_EDITOR="nvim"
export PATH="$HOME/.config/emacs/bin:$PATH"
suspend() {
    swaylock -f -i $HOME/Images/ScreenShots/2026-04-24_02-04-12.png
    sleep 1
    systemctl suspend
}


catr() {
  for f in "$@"; do
    printf "\n── FILE: %s ──\n" "$f"
    cat "$f"
  done
}
# Usage: catr ~/vimwiki/*.md > consolidated_logs.txt
