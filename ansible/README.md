## Layout
Follows the Ansible "sample setup" layout, supporting both **Fedora** (`RedHat` / DNF5 + RPM Fusion + COPR) and **Ubuntu** (`Debian` / APT):

```text
ansible.cfg                      # inventory + roles_path
requirements.yml                 # collections (community.general, ansible.posix)
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
| `common` | base CLI tools, `libimobiledevice-utils`, RPM Fusion + `intel-media-driver` (Fedora) |
| `dev` | `ripgrep`, `fd`, `fzf`, `ansible-lint`, compilers, `nodejs` |
| `neovim` | latest Neovim tarball in `/opt` |
| `desktop` | `libreoffice`, `vlc`, `gimp`, `fcitx5` + Bamboo, `tlp` + `tlp-pd` (removes `tuned-ppd`/`power-profiles-daemon`), Source Code Pro & Hack Nerd Font Mono |
| `audio` | `pipewire` + `wireplumber` + xdg portals (dependency of `niri`) |
| `niri` | `niri` + `noctalia` + `alacritty` + `fuzzel` + Wayland utilities |
| `flatpak` | `flatpak`, `flathub`, Stremio |
| `docker` | `docker-ce`, enables `docker.service`, adds user to `docker` group |
| `browsers` | standard `firefox`, `google-chrome-stable` |
| `apps` | `discord`, `obsidian` (`/opt/Obsidian` tarball on Fedora), `localsend` (`/opt/LocalSend` tarball on Fedora, + `firewalld` 53317), `anydesk`, `obs-studio`, `anki` |
| `k8s` | `kubectl`, `kind`, and `/etc/sysctl.d/99-k8s.conf` inotify limits |
| `user_tools` | `rustup`, `zed`, `opencode`, `agy` (as user) |
| `thinkpad` | ThinkPad TLP battery thresholds (`--tags thinkpad`); optional I2C touchpad/IRQ fixes via `-e thinkpad_touchpad_fix=true` |
| `monitoring` | `node_exporter` systemd service |

## Bootstrap
```bash
# Fedora:
sudo dnf install -y ansible ansible-lint
# Ubuntu:
sudo apt install -y ansible ansible-lint

ansible-galaxy collection install -r requirements.yml
```

## Usage
Add `-K` (`--ask-become-pass`) if `sudo` asks for a password on a fresh machine.
```bash
ansible-playbook site.yml                     # everything (except opt-in roles like thinkpad)
ansible-playbook site.yml --tags docker       # one role
ansible-playbook site.yml --tags thinkpad     # ThinkPad-specific hardware tuning
ansible-playbook site.yml --check --diff      # dry run
ansible-lint                                  # lint all playbooks/roles
```
Versions to bump live in `inventories/local/group_vars/all.yml`.
