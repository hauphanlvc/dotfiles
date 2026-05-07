# shellcheck shell=bash

[[ $- != *i* ]] && return

# avoid duplicates..
function set_history() {
  # Increase history size
  export HISTSIZE=100000
  export HISTFILESIZE=200000
  export HISTCONTROL=ignoreboth:erasedups

  # append history entries..
  shopt -s histappend

  # After each command, save and reload history
  # export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
  export PROMPT_COMMAND="history -a; history -n;"

}

function load_alias() {
  # alias
  if [ -s "$HOME/.alias" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.alias"
  fi
  alias l='ls -alFh --color=auto'
  alias la='ls -lah --color=auto'
  alias ll='ls -alFh --color=auto'
  alias ls='ls -h --color=auto'
  alias ls-l='ls -lh --color=auto'
  alias rm="rm -i"
}
function load_fzf_config() {

  export FZF_DEFAULT_COMMAND='rg --hidden --files'
  export FZF_DEFAULT_OPTS="--layout=reverse --border --height=60%"
  # Print tree structure in the preview window
  export FZF_ALT_C_COMMAND="ls -a"
  export FZF_ALT_C_OPTS="--preview 'tree -C -a {}'"

}
# Git Prompt Setup
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

define_colors() {
  # Define colors
  YELLOW="\[\033[0;33m\]"
  RESET="\[\033[0m\]" # Reset color
}

add_more_PATH() {
  # export PATH="~/.local/share/apache-maven-3.9.8/bin/:$PATH"
  export PATH="$PATH:$HOME/bin"
  export PATH="$PATH:/usr/local/go/bin"
  if command -v go >/dev/null 2>&1; then
    local gopath
    gopath="$(go env GOPATH)"
    if [[ -n "$gopath" ]]; then
      export PATH="$PATH:$gopath/bin"
    fi
  fi
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh" # This loads nvm
  fi
  if [ -s "$NVM_DIR/bash_completion" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/bash_completion" # This loads nvm bash_completion
  fi

  #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
  export SDKMAN_DIR="$HOME/.sdkman"
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}
if [ -f /etc/bash_completion ]; then
  # shellcheck source=/dev/null
  source /etc/bash_completion
fi

set_history
load_alias
# load_fzf_config
add_more_PATH
define_colors
PS1="$YELLOW\$(parse_git_branch)$RESET\u@\h[\A][\w]\$ "
export PS1
export DISPLAY="${DISPLAY:-:0}"

if command -v terraform >/dev/null 2>&1; then
  complete -C "$(command -v terraform)" terraform
fi
