# Dotfiles & Workstation Automation

Personal Linux workstation setup combining **Ansible** (Dual-OS **Fedora** & **Ubuntu** provisioning for system packages, repositories, developer tools, and ThinkPad hardware tuning) and **symlinked user configurations** (`config/` + `link-config.sh`).

> For the step-by-step **Windows 11 + Fedora 45 dual-boot & post-provision checklist**, see [MIGRATION.md](MIGRATION.md).

---

## 1. Repository Layout

```text
dotfiles/
├── README.md                        # Main documentation
├── link-config.sh                   # Creates symlinks from ~/.config, ~/.bashrc.user, ~/.gitconfig, ~/iphone-battery.sh
├── scripts/
│   └── iphone-battery.sh            # iPhone battery diagnostics via libimobiledevice
├── config/                          # User configuration files (tracked in Git)
│   ├── alacritty/alacritty.toml     # Alacritty terminal config
│   ├── bash/bashrc.user             # User shell environment, PATH, k8s aliases (~/.bashrc.user)
│   ├── environment.d/im.conf        # Wayland IME environment (fcitx5)
│   ├── fcitx5/{config,profile}      # Fcitx5 + Bamboo Vietnamese input config
│   ├── git/gitconfig                # Git identity & default editor (~/.gitconfig)
│   ├── lazyvim/                     # LazyVim configuration profile
│   ├── niri/config.kdl              # Niri scrollable-tiling Wayland compositor config
│   ├── nvim/init.lua                # Custom minimal Neovim 0.12 configuration (vim.pack)
│   ├── tmux/tmux.conf               # Tmux config
│   └── zed/settings.json            # Zed editor settings
└── ansible/                         # Dual-OS (Fedora DNF + Ubuntu APT) Ansible playbooks & roles
    ├── ansible.cfg                  # Default inventory & roles_path
    ├── requirements.yml             # Required collections (community.general, ansible.posix)
    ├── site.yml                     # Main entry playbook (imports workstation.yml)
    ├── workstation.yml              # Workstation provisioning playbook
    ├── monitoring.yml               # Systemd node_exporter playbook (reference)
    ├── monitoring/                  # Docker Compose Prometheus + Grafana + node-exporter stack
    ├── inventories/local/           # Localhost inventory & pinned package versions (all.yml)
    └── roles/                       # Modular Ansible roles
```

---

## 2. User Configurations (`config/` & `link-config.sh`)

Both of your Neovim configurations are preserved in `config/`:
- **`config/nvim/init.lua`**: Minimal Neovim 0.12 configuration (`vim.pack.add`, native LSP completion).
- **`config/lazyvim/`**: Full LazyVim configuration.

### Linking Dotfiles
Run `./link-config.sh` once to create symbolic links from `~/.config/*`, `~/.bashrc.user`, `~/.gitconfig`, and `~/iphone-battery.sh` into `~/dotfiles`:

```bash
# Default: Link active configs and point ~/.config/nvim -> ~/dotfiles/config/lazyvim
./link-config.sh

# Switch ~/.config/nvim to custom minimal Neovim config (config/nvim/init.lua)
./link-config.sh --nvim=nvim

# Switch ~/.config/nvim back to LazyVim (config/lazyvim)
./link-config.sh --nvim=lazyvim
```

---

## 3. Ansible Workstation Provisioning (`ansible/`)

Ansible supports both **Fedora (`RedHat` / DNF5 + RPM Fusion + COPR)** and **Ubuntu (`Debian` / APT)**.

### What Each Ansible Role Does

| Role / Tag | Default? | What It Installs & Configures |
| :--- | :---: | :--- |
| `common` | Yes | Base CLI tools (`git`, `tmux`, `vim`, `htop`, `btop`, `ffmpeg`, `libimobiledevice-utils`, etc.) + **RPM Fusion** & `intel-media-driver` on Fedora |
| `dev` | Yes | Developer CLI tools (`ripgrep`, `fd-find`, `fzf`, `ansible-lint`, compilers) + **Node.js** |
| `neovim` | Yes | Latest **Neovim** release tarball installed to `/opt/nvim-linux-x86_64` and registered as `/usr/bin/nvim` via `alternatives` |
| `desktop` | Yes | Desktop apps & utilities (`libreoffice`, `vlc`, `gimp`, `fcitx5` + Bamboo, `tlp`, `fwupd`, **Source Code Pro** & **Hack Nerd Font Mono**; removes `tuned-ppd` on Fedora / `power-profiles-daemon` on Ubuntu) |
| `audio` | *(dep)* | `pipewire`, `wireplumber`, and `xdg-desktop-portal` packages (pulled in as a dependency of `niri`) |
| `niri` | Yes | **Niri** + **Noctalia** (`yalter/niri` + `zhangyi6324/noctalia-shell` COPRs on Fedora; `danklinux` + `noctalia` on Ubuntu), `alacritty`, `fuzzel`, `xwayland-satellite`/`xwayland`, `grim`, `slurp`, `wl-clipboard` |
| `flatpak` | Yes | `flatpak`, Flathub remote, and **Stremio** |
| `docker` | Yes | Official **Docker CE** (`docker-ce`, `docker-buildx-plugin`, `docker-compose-plugin`), enables `docker.service`, and adds user to the `docker` group |
| `browsers` | Yes | Standard **Firefox** and **Google Chrome** |
| `apps` | Yes | **Discord**, **Obsidian** (GitHub `.tar.gz` -> `/opt/Obsidian` on Fedora, `.deb` on Ubuntu), **LocalSend** (+ `firewalld` port `53317` on Fedora), **AnyDesk**, **OBS Studio**, **Anki** |
| `k8s` | Yes | **kubectl**, **kind** binary, and `/etc/sysctl.d/99-k8s.conf` inotify limits |
| `user_tools` | Yes | User-space installers without sudo: **Rustup** (`~/.cargo`), **Zed** (`~/.local/bin/zed`), **OpenCode** (`~/.opencode`), **Antigravity CLI** (`~/.local/bin/agy`) |
| `thinkpad` | **Opt-in** (`never`) | **ThinkPad T14 Gen 3 hardware fixes**:<br/>• `/etc/tlp.d/01-thinkpad.conf` (75–80% battery thresholds + `intel-lpss` `00:15.0` Runtime PM denylist)<br/>• `/etc/udev/rules.d/99-touchpad-i2c-power.rules` (locks I2C/LPSS Runtime PM to `on` + dynamically pins `i2c_designware.0` / `ELAN0676:00` IRQs to `CPU2`/`CPU3`)<br/>• `/usr/lib/systemd/system-sleep/touchpad-i2c-resume` (clean `i2c_hid_acpi` rebind + dynamic IRQ pinning after S3 `deep` suspend) |
| `monitoring` | Separate playbook | Installs `node_exporter` systemd service via `monitoring.yml` (alternative to the Docker Compose stack in `ansible/monitoring/`) |

### How to Run Ansible

1. **Bootstrap Ansible (first time on a new machine):**
   ```bash
   # Fedora:
   sudo dnf install -y ansible ansible-lint

   # Ubuntu:
   sudo apt update && sudo apt install -y ansible ansible-lint

   cd ~/dotfiles/ansible
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Run Playbooks:**
   ```bash
   cd ~/dotfiles/ansible

   # Run the full workstation setup (skips opt-in roles tagged 'never' like 'thinkpad')
   ansible-playbook site.yml -K

   # Run only specific role(s) by tag
   ansible-playbook site.yml --tags niri -K

   # Apply ThinkPad-specific touchpad & power management rules (opt-in role)
   ansible-playbook site.yml --tags thinkpad -K

   # Dry-run (check mode with diff) to preview changes without modifying the system
   ansible-playbook site.yml --check --diff

   # Lint all playbooks and roles
   ansible-lint
   ```

3. **Bumping Pinned Versions:**
   Pinned versions (`anki_version`, `kubectl_version`, `kind_version`, `node_exporter_version`, `nodejs_major`) live in [`ansible/inventories/local/group_vars/all.yml`](ansible/inventories/local/group_vars/all.yml).
