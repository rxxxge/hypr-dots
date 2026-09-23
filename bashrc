#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)")'; PS1='\u@\h \w${PS1_CMD1}  '

# [[ -f ~/.local/state/topia/sequences.txt ]] && cat ~/.local/state/topia/sequences.txt

export PATH="$PATH:~/.local/bin"
export UTILS="SystemUtils"

alias ls='eza --group-directories-first -1'

#-----
export NNN_OPTS="H" # 'H' shows the hidden files. Same as option -H (so 'nnn -deH')
# export NNN_OPTS="deH" # if you prefer to have all the options at the same place
export LC_COLLATE="C" # hidden files on top
export NNN_FCOLORS="AAAAE631BBBBCCCCDDDD9999" # feel free to change the colors
export NNN_PLUG='p:preview-tui' # many other plugins are available here: https://github.com/jarun/nnn/tree/master/plugins
export SPLIT='v' # to split Kitty vertically
#-----

source ~/$UTILS/.git-prompt.sh
