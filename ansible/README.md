## Layout
Follows the Ansible "sample setup" layout:

```
ansible.cfg                      # inventory + roles_path
requirements.yml                 # collections (community.general)
inventories/local/hosts.ini      # localhost
inventories/local/group_vars/    # all.yml: target_user + pinned versions
site.yml                         # imports workstation.yml + monitoring.yml
workstation.yml                  # desktop/dev roles
monitoring.yml                   # node_exporter
monitoring/                      # standalone prometheus/grafana docker-compose
roles/<role>/{tasks,defaults,meta,handlers,templates,files}
```

| Role (tag) | Installs |
|---|---|
| `common` | base CLI tools (git, tmux, vim, htop, btop, ffmpeg, ...) |
| `dev` | ripgrep, fd, fzf, nodejs (NodeSource) |
| `neovim` | latest Neovim tarball in /opt + init.lua symlink |
| `desktop` | libreoffice, vlc, gimp, fonts, fcitx5, tlp, fwupd, ... |
| `audio` | pipewire + xdg portals (dependency of sway/niri) |
| `sway` | sway + wayland utilities |
| `niri` | niri (danklinux PPA) + noctalia |
| `flatpak` | flatpak, flathub, Stremio |
| `docker` | docker-ce + adds the user to the `docker` group |
| `browsers` | brave nightly, zen, firefox-devedition, chrome, edge |
| `apps` | discord, obsidian, localsend, anydesk, obs-studio, anki |
| `k8s` | kubectl, kind |
| `user_tools` | rustup, zed, opencode, antigravity cli (as user) |
| `monitoring` | node_exporter systemd service |

## Bootstrap
```bash
sudo apt install ansible
ansible-galaxy collection install -r requirements.yml
```

## Usage
```bash
ansible-playbook site.yml -K                  # everything
ansible-playbook site.yml --tags docker -K    # one role
ansible-playbook site.yml --check --diff -K   # dry run
```
Versions to bump live in `inventories/local/group_vars/all.yml`.

## Notes:
- Why need to add don't ask sudo password in the current user?
    + You don't need to put the password for any tasks need to use
- Why should seperate all tasks to small yaml files?
    + Easily manage all of them
