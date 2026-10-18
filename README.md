# Dotfiles & Workstation Automation

Personal Linux workstation setup combining **Ansible** (for system packages, repositories, developer tools, and hardware tuning) and **symlinked user configurations** (`config/` + `link-config.sh`).

---

## 1. Repository Layout

```text
dotfiles/
├── README.md                        # Main documentation
├── link-config.sh                   # Creates symlinks from ~/.config & ~/.bashrc.user -> ./config
├── config/                          # User configuration files (tracked in Git)
│   ├── alacritty/alacritty.toml     # Alacritty terminal config
│   ├── bash/bashrc.user             # User shell environment & history settings (~/.bashrc.user)
│   ├── i3/config                    # i3wm config (archived/optional)
│   ├── i3status/config              # i3status bar config (coretemp + BAT0)
│   ├── kitty/kitty.conf             # Kitty terminal config (archived/optional)
│   ├── lazyvim/                     # LazyVim configuration profile
│   ├── niri/config.kdl              # Niri scrollable-tiling Wayland compositor config
│   ├── nvim/init.lua                # Custom minimal Neovim 0.12 configuration (vim.pack)
│   ├── sway/config                  # Sway Wayland compositor config
│   ├── tmux/tmux.conf               # Tmux config
│   └── zed/settings.json            # Zed editor settings
└── ansible/                         # Ansible playbooks & roles for system provisioning
    ├── ansible.cfg                  # Default inventory & roles_path
    ├── requirements.yml             # Required Ansible collections (community.general)
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
- **`config/nvim/init.lua`**: Your custom minimal Neovim 0.12 configuration (`vim.pack.add`, native LSP completion).
- **`config/lazyvim/`**: Your full LazyVim configuration.

### Linking Dotfiles
Run `./link-config.sh` once to create symbolic links from `~/.config/*` and `~/.bashrc.user` directly into `~/dotfiles/config/*`. Because the directories themselves are symlinked, any edits you make in `~/.config/` are immediately reflected in this Git repository—no cron jobs or manual syncing required.

```bash
# Default: Link active configs (alacritty, i3status, niri, sway, tmux, zed, bashrc.user)
# and point ~/.config/nvim -> ~/dotfiles/config/lazyvim
./link-config.sh

# Switch ~/.config/nvim to your custom minimal Neovim config (config/nvim/init.lua)
./link-config.sh --nvim=nvim

# Switch ~/.config/nvim back to LazyVim (config/lazyvim)
./link-config.sh --nvim=lazyvim

# Also link optional archived configs (i3 and kitty)
./link-config.sh --all
```

---

## 3. Ansible Workstation Provisioning (`ansible/`)

Ansible handles package installation, third-party APT repositories (using deb822 `.sources` + `/etc/apt/keyrings/`), standalone binaries, and hardware-specific system rules.

### What Each Ansible Role Does

| Role / Tag | Default? | What It Installs & Configures |
| :--- | :---: | :--- |
| `common` | Yes | Base CLI utilities (`git`, `tmux`, `vim`, `htop`, `btop`, `ffmpeg`, `curl`, `wget`, `unzip`, `jq`, etc.) |
| `dev` | Yes | Developer CLI tools (`ripgrep`, `fd-find`, `fzf`, `ansible-lint`, `build-essential`) + **Node.js** via NodeSource |
| `neovim` | Yes | Latest **Neovim** release tarball installed to `/opt/nvim-linux-x86_64` and registered as `/usr/bin/nvim` via `alternatives` |
| `desktop` | Yes | Desktop apps & utilities (`libreoffice`, `vlc`, `gimp`, `fcitx5` + Unikey, `gammastep`, `tlp`, `fwupd`, `wl-clipboard`, `grim`, `slurp`, Adobe **Source Code Pro** OTF fonts) |
| `audio` | *(dep)* | `pipewire`, `wireplumber`, and `xdg-desktop-portal` packages (automatically pulled in as a dependency of `sway` and `niri`) |
| `sway` | Yes | **Sway** Wayland compositor (`sway`, `swaylock`, `swayidle`, `swaybg`, `i3status`, `wmenu`) |
| `niri` | Yes | **Niri** compositor (via `ppa:avengemedia/danklinux`) + **Noctalia** status bar (`pkg.noctalia.dev`) |
| `flatpak` | Yes | `flatpak`, Flathub remote, and **Stremio** |
| `docker` | Yes | Official **Docker CE** (`docker-ce`, `docker-buildx-plugin`, `docker-compose-plugin`) and adds user to the `docker` group |
| `browsers` | Yes | **Brave Nightly**, **Zen Browser** (`/opt/zen`), **Firefox Developer Edition**, **Google Chrome**, **Microsoft Edge** |
| `apps` | Yes | **Discord**, **Obsidian**, **LocalSend**, **AnyDesk**, **OBS Studio**, **Anki** |
| `k8s` | Yes | **kubectl** (official Kubernetes APT repo) and **kind** binary |
| `user_tools` | Yes | User-space installers run without sudo: **Rustup** (`~/.cargo`), **Zed** (`~/.local/bin/zed`), **OpenCode** (`~/.opencode`), **Antigravity CLI** (`~/.local/bin/agy`) |
| `thinkpad` | **Opt-in** (`never`) | **ThinkPad T14 Gen 3 hardware fixes**:<br/>• `/etc/tlp.d/01-thinkpad.conf` (75–80% battery thresholds + `intel-lpss` `00:15.0` Runtime PM denylist)<br/>• `/etc/udev/rules.d/99-touchpad-i2c-power.rules` (locks I2C/LPSS Runtime PM to `on` + pins touchpad IRQs `27`/`56` to `CPU2`/`CPU3`)<br/>• `/usr/lib/systemd/system-sleep/touchpad-i2c-resume` (clean `i2c_hid_acpi` rebind after S3 `deep` suspend) |
| `monitoring` | Separate playbook | Installs `node_exporter` systemd service via `monitoring.yml` (alternative to the Docker Compose stack in `ansible/monitoring/`) |

### How to Run Ansible

1. **Bootstrap Ansible (first time on a new machine):**
   ```bash
   sudo apt update && sudo apt install -y ansible
   cd ~/dotfiles/ansible
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Run Playbooks:**
   ```bash
   cd ~/dotfiles/ansible

   # Run the full workstation setup (skips opt-in roles tagged 'never' like 'thinkpad')
   ansible-playbook site.yml

   # Run only specific role(s) by tag
   ansible-playbook site.yml --tags niri
   ansible-playbook site.yml --tags "neovim,dev"

   # Apply ThinkPad-specific touchpad & power management rules (opt-in role)
   ansible-playbook site.yml --tags thinkpad

   # Dry-run (check mode with diff) to preview changes without modifying the system
   ansible-playbook site.yml --check --diff

   # Lint all playbooks and roles
   ansible-lint
   ```
   *(Note: If `sudo` requires a password on a new machine, append `-K` / `--ask-become-pass` to `ansible-playbook`.)*

3. **Bumping Pinned Versions:**
   Package versions for GitHub/tarball releases (`obsidian`, `localsend`, `anki`, `zen`, `kind`, `node_exporter`, `nodejs_major`) are centralized in [`ansible/inventories/local/group_vars/all.yml`](ansible/inventories/local/group_vars/all.yml).
