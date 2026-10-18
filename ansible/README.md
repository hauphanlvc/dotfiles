## Layout
Follows the Ansible "sample setup" layout:

```
ansible.cfg                      # inventory + roles_path
requirements.yml                 # collections (community.general)
inventories/local/hosts.ini      # localhost
inventories/local/group_vars/    # all.yml: target_user + pinned versions
site.yml                         # imports workstation.yml (monitoring.yml is commented out)
workstation.yml                  # desktop/dev roles
monitoring.yml                   # node_exporter (kept as a learning reference)
monitoring/                      # standalone prometheus/grafana docker-compose
roles/<role>/{tasks,defaults,meta,handlers,templates,files}
```

| Role (tag) | Installs |
|---|---|
| `common` | base CLI tools (git, tmux, vim, htop, btop, ffmpeg, ...) |
| `dev` | ripgrep, fd, fzf, ansible-lint, nodejs (NodeSource) |
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
| `thinkpad` | ThinkPad TLP thresholds, I2C touchpad udev power rule, suspend-resume hook (skipped by default; run with `--tags thinkpad`) |
| `monitoring` | node_exporter systemd service |

## Bootstrap
```bash
sudo apt install ansible
ansible-galaxy collection install -r requirements.yml
```

## Usage
`sudo` is passwordless for my user, so no `-K` is needed
(add `-K` on a machine where sudo asks for a password).
```bash
ansible-playbook site.yml                     # everything (except opt-in roles like thinkpad)
ansible-playbook site.yml --tags docker       # one role
ansible-playbook site.yml --tags thinkpad     # ThinkPad-specific hardware tuning
ansible-playbook site.yml --check --diff      # dry run
ansible-lint                                  # lint all playbooks/roles
```
Versions to bump live in `inventories/local/group_vars/all.yml`.

## Notes
- Why allow passwordless sudo for the current user?
    + Ansible can run every `become` task without asking for a password.
- Why separate tasks into small yaml files / roles?
    + Easier to manage, and each role can be run alone with `--tags`.
- Third-party apt repos are added as a key in `/etc/apt/keyrings/` plus a
  deb822 `.sources` file, the same way the vendors document it, so there is
  no extra Python dependency (`deb822_repository` would need `python3-debian`).
- `monitoring.yml` (systemd node_exporter) is kept as a reference only. Don't
  run it while the docker-compose stack in `monitoring/` is up: both use port 9100.
