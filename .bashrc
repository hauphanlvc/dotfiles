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
  test -s ~/.alias && . ~/.alias || true
  alias l='ls -alFh --color=auto'
  alias la='ls -lah --color=auto'
  alias ll='ls -alFh --color=auto'
  alias ls='ls -h --color=auto'
  alias ls-l='ls -lh --color=auto'
  alias vim='nvim'
  alias rm="rm -i"
}
function load_fzf_config() {

  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  export FZF_DEFAULT_COMMAND='rg --hidden --files'
  export FZF_DEFAULT_OPTS="--layout=reverse --border --height=60%"
  # Print tree structure in the preview window
  export FZF_ALT_C_COMMAND="ls -a"
  export FZF_ALT_C_OPTS="--preview 'tree -C -a {}'"

}
# Git Prompt Setup
check_git_version() {
    local required_version="1.9.3"
    local git_version
    git_version=$(git --version | awk '{print $3}')

    if [[ $(printf "%s\n" "$required_version" "$git_version" | sort -V | head -n1) == "$required_version" ]]; then
        return 0  # Git version is >= 1.9.3
    else
        return 1  # Git version is < 1.9.3
    fi
}

parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

define_colors() {
    # Define colors
    RED="\[\033[0;31m\]"
    GREEN="\[\033[0;32m\]"
    YELLOW="\[\033[0;33m\]"
    BLUE="\[\033[0;34m\]"
    MAGENTA="\[\033[0;35m\]"
    CYAN="\[\033[0;36m\]"
    RESET="\[\033[0m\]"  # Reset color
}

load_git_prompt_PS1() {

    if check_git_version; then
        if [[ -f "$HOME/.git-prompt.sh" ]]; then
            source ~/.git-prompt.sh
            PS1="$YELLOW\$(__git_ps1 "[%s]")$PS1"
            return
        fi

        git_prompt_file=$(find / -type f -regex '.*/git-\(prompt\.sh\|sh-prompt\)' -print -quit 2>/dev/null)
        if [[ -n "$git_prompt_file" ]]; then
            cp "$git_prompt_file" ~/.git-prompt.sh
            source ~/.git-prompt.sh
            PS1="$YELLOW\$(__git_ps1 "[%s]")$PS1"
        else
            echo "git-prompt.sh not found. Using fallback."
            PS1="[$(parse_git_branch)]$PS1"
        fi
    else
            PS1="$(parse_git_branch)$PS1"
    fi
}
set_neovim_is_default() {
    if command -v nvim &>/dev/null; then
        # Set neovim as the default editor
        EDITOR=nvim
    else
        # Fallback to vim if neovim is not installed
        EDITOR=vim
    fi
    export EDITOR
}
add_more_PATH() {
    # export PATH="~/bin/:$PATH"
    # export PATH="~/.local/share/apache-maven-3.9.8/bin/:$PATH"
    export PATH=$PATH:/usr/local/go/bin
    export PATH=$PATH:$(go env GOPATH)/bin
}
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# uexport PS1="$(tput setaf 39)\u@$(tput setaf 51)\h $(tput setaf 2)$(date +"%H:%M:%S") $(tput setaf 62)\w$(tput setaf 11)\$(parse_git_branch) $(tput sgr0)$ "
# export PS1="\u@\h[\A][\w]\$(__git_ps1 "[%s]")\$ "
set_history
load_alias
load_fzf_config
add_more_PATH
define_colors
PS1="$RESET\u@\h[\A][\w]\$ "
load_git_prompt_PS1 && export PS1
export DISPLAY=:0

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
