#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="${DOTFILES_DIR}/config"
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Default Neovim profile: "lazyvim" (points ~/.config/nvim -> ~/dotfiles/config/lazyvim)
# Pass --nvim=nvim to point ~/.config/nvim -> ~/dotfiles/config/nvim
NVIM_PROFILE="lazyvim"

CONFIG_DIRS=(
    "alacritty"
    "i3status"
    "niri"
    "sway"
    "tmux"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--nvim=lazyvim|nvim] [--all]

Creates symbolic links from ~/.config/* and ~/.bashrc.user -> ~/dotfiles/config/*

Options:
  --nvim=lazyvim   Link ~/.config/nvim -> ~/dotfiles/config/lazyvim (default)
  --nvim=nvim      Link ~/.config/nvim -> ~/dotfiles/config/nvim (custom init.lua)
  --all            Also link i3 and kitty configs into ~/.config/
EOF
}

for arg in "$@"; do
    case "$arg" in
        --nvim=lazyvim|--nvim=nvim)
            NVIM_PROFILE="${arg#--nvim=}"
            ;;
        --all)
            CONFIG_DIRS+=("i3" "kitty")
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

link_dir() {
    local src_dir="$1"
    local dest_dir="$2"

    if [[ ! -d "$src_dir" ]]; then
        echo "Skipping missing repo dir: $src_dir"
        return
    fi

    # If dest_dir is a real directory (not a symlink yet), copy any newer files into src_dir first
    if [[ -d "$dest_dir" && ! -L "$dest_dir" ]]; then
        rsync -au "$dest_dir/" "$src_dir/"
        rm -rf "$dest_dir"
    fi

    ln -sfn "$src_dir" "$dest_dir"
    echo "Linked: $dest_dir -> $(readlink "$dest_dir")"
}

link_file() {
    local src_file="$1"
    local dest_file="$2"

    mkdir -p "$(dirname "$dest_file")"
    if [[ -f "$dest_file" && ! -L "$dest_file" ]]; then
        rsync -au "$dest_file" "$src_file"
    fi

    ln -sfn "$src_file" "$dest_file"
    echo "Linked: $dest_file -> $(readlink "$dest_file")"
}

mkdir -p "$USER_CONFIG_DIR"

for dir in "${CONFIG_DIRS[@]}"; do
    link_dir "${REPO_CONFIG_DIR}/${dir}" "${USER_CONFIG_DIR}/${dir}"
done

# Link ~/.config/nvim to the selected Neovim profile (lazyvim or custom nvim)
if [[ -d "${USER_CONFIG_DIR}/nvim" && ! -L "${USER_CONFIG_DIR}/nvim" ]]; then
    rm -rf "${USER_CONFIG_DIR}/nvim"
fi
ln -sfn "${REPO_CONFIG_DIR}/${NVIM_PROFILE}" "${USER_CONFIG_DIR}/nvim"
echo "Linked: ${USER_CONFIG_DIR}/nvim -> $(readlink "${USER_CONFIG_DIR}/nvim")"

# Link single files
link_file "${REPO_CONFIG_DIR}/bash/bashrc.user" "${HOME}/.bashrc.user"
link_file "${REPO_CONFIG_DIR}/zed/settings.json" "${USER_CONFIG_DIR}/zed/settings.json"
