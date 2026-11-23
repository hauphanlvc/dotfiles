# Dual-Boot Migration & Post-Provision Runbook (Windows 11 + Fedora 45)

This guide covers every step from backing up your current Ubuntu 26.04 setup through installing **Windows 11** (for CKA + Office), installing **Fedora 45**, running your Dual-OS Ansible setup, and verifying all apps and ThinkPad hardware fixes afterward.

---

## Phase 1: Pre-Wipe Checklist (On Ubuntu Now)

1. **Commit and push Git repositories:**
   ```bash
   # 1. Dotfiles (includes Dual-OS Ansible, niri, bashrc.user, fcitx5, gitconfig, iphone-battery.sh)
   cd ~/dotfiles
   git status
   git add -A
   git commit -m "feat: add Dual-OS Fedora/Ubuntu support and finalize workstation configs"
   git push

   # 2. Notes (includes .obsidian/plugins/ for Excalidraw, Templater, Flashcards)
   cd ~/Notes
   git status
   git add .gitignore .obsidian/plugins
   git commit -m "chore(notes): track Obsidian community plugins and configs"
   git push
   ```
   *(Verify [Notes/.gitignore](.gitignore) keeps `*.log` ignored so `sync.log` is not committed.)*

2. **Sync cloud accounts:**
   - **Anki:** Open Anki and run **Sync** to upload your latest `User 1` deck & scheduling state to AnkiWeb.
   - **Firefox:** Verify **Mozilla Sync** is signed in and synced.
   - **Google Chrome:** Verify **Chrome Sync** is signed in and synced.

3. **Back up local directories to USB/external storage (`~25 MB` total):**
   ```bash
   mkdir -p /tmp/ubuntu-backup
   tar -czf /tmp/ubuntu-backup/local-backup.tar.gz \
     -C "$HOME" \
     .ssh \
     .kube/config \
     .azure \
     .gemini/config \
     Documents \
     Pictures
   ```
   Copy `/tmp/ubuntu-backup/local-backup.tar.gz` to your USB drive/cloud and remove `/tmp/ubuntu-backup/` when done.

---

## Phase 2: Install Windows 11 (First)

Install Windows 11 **before** Fedora so Windows Boot Manager does not overwrite Fedora's EFI boot order.

1. **Partitioning (`nvme0n1`):**
   - Create a **`~100–120 GB` NTFS** partition for Windows 11, Office, and the PSI Secure Browser.
   - Leave the remaining NVMe space **unallocated** for Fedora 45.
   - Use **Windows 11 Home or Pro** (not S-Mode, not Enterprise/Education with restrictive policies).
   - Keep **Secure Boot ON** and **TPM 2.0 ON** in BIOS; keep **BitLocker OFF** (or save the recovery key) until dual-boot is finished.

2. **Post-install Windows 11 tweaks (Admin Command Prompt):**
   ```cmd
   :: 1. Disable Fast Startup / hibernation so NVMe & Wi-Fi don't stay locked on reboot to Fedora
   powercfg /h off

   :: 2. Use UTC hardware clock so Windows & Fedora don't drift by +7 hours (critical for CKA TLS/check-in)
   reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
   ```

3. **CKA Exam (PSI Bridge Secure Browser) checklist:**
   - **Unplug your external monitor (`DP-1`)** before launching the exam—PSI strictly enforces a single display (`eDP-1` only).
   - Disable VPNs, OneDrive sync, and background overlays before running the PSI system check.
   - Disable Windows sleep/screen-off during the exam window.

---

## Phase 3: Install Fedora 45 (Second)

1. **BIOS check:** Ensure Sleep State stays on **`Linux S3`** (not Windows/Modern Standby) so the ThinkPad I2C touchpad resume hook behaves consistently.
2. **Anaconda Installer:**
   - Select **Btrfs** (Fedora default) in the **unallocated** NVMe space.
   - Reuse the existing **FAT32 EFI System Partition** mounted at `/boot/efi` (**do not format** `/boot/efi`, or you will erase Windows Boot Manager).
   - Create your user as **`hau`** with administrator (wheel) privileges.

---

## Phase 4: Restore Data & Provision Fedora

1. **Restore local backups & SSH permissions:**
   ```bash
   # Extract local backup from your USB drive
   tar -xzf /path/to/local-backup.tar.gz -C "$HOME"

   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

2. **Install Git & Ansible, then clone your repos:**
   ```bash
   sudo dnf install -y git ansible ansible-lint

   git clone git@github.com:hauphanlvc/dotfiles.git ~/dotfiles
   git clone git@github.com:hauphanlvc/Notes.git ~/Notes
   ```

3. **Link dotfiles & user configs:**
   ```bash
   cd ~/dotfiles
   ./link-config.sh
   # (Pass --nvim=nvim if you want minimal init.lua instead of LazyVim)
   ```
   Also ensure `~/.bashrc` sources `~/.bashrc.user`:
   ```bash
   grep -q 'bashrc.user' ~/.bashrc || printf '\nif [ -f ~/.bashrc.user ]; then\n    . ~/.bashrc.user\nfi\n' >> ~/.bashrc
   ```

4. **Run Ansible provisioning:**
   ```bash
   cd ~/dotfiles/ansible
   ansible-galaxy collection install -r requirements.yml

   # Full workstation setup (prompts for sudo password with -K)
   ansible-playbook site.yml -K

   # Apply ThinkPad T14 Gen 3 battery thresholds & I2C touchpad fixes
   ansible-playbook site.yml --tags thinkpad -K
   ```
   *(Reboot or log out and select **Niri** at the login screen.)*

5. **Restore Anki, Obsidian & Browsers:**
   - **Anki:** Launch `anki`, log into **AnkiWeb** and **Sync**, then go to **Tools → Add-ons → Get Add-ons...** and install code **`2055492159`** (**AnkiConnect**), then restart Anki.
   - **Obsidian:** Launch Obsidian from your app launcher (`fuzzel` via `Mod+D`) or `obsidian`, open existing vault **`~/Notes`**, and confirm **Community Plugins** are enabled (`Excalidraw`, `Templater`, `Flashcards`).
   - **Browsers:** Sign into **Mozilla Sync** in Firefox and **Chrome Sync** in Google Chrome.
   - **User Tools (`zed`, `opencode`, `agy`):** Log into each CLI/editor as needed.

---

## Phase 5: Post-Provision Verification Checklist (On Fedora)

Run these checks once you're logged into your **Niri** session:

### 1. Niri, Noctalia & Wayland Input (`fcitx5`)
- Verify Noctalia binary name:
  ```bash
  command -v noctalia || command -v noctalia-shell
  ```
  *(If Fedora's COPR package installs `noctalia-shell` or `qs -c noctalia-shell` instead of `noctalia`, update `spawn-at-startup` in `~/.config/niri/config.kdl` accordingly.)*
- Verify `fcitx5` environment variables & Bamboo typing:
  ```bash
  env | grep -E 'XMODIFIERS|QT_IM_MODULE'
  pgrep -a fcitx5
  ```
  Test Vietnamese input with `Super+Space` / `Ctrl+Shift+LShift` in Alacritty, Firefox, and Obsidian.

### 2. ThinkPad T14 Gen 3 Hardware & Power (`TLP` + Touchpad + S3)
```bash
# 1. Confirm tuned-ppd is gone and TLP is active with 75–80% battery thresholds
systemctl is-active tlp
sudo tlp-stat -b | grep -E 'charge_control|threshold'

# 2. Confirm S3 deep sleep is active
cat /sys/power/mem_sleep
# Expected: s2idle [deep]
# If it shows [s2idle], set Linux S3 in BIOS or run:
# sudo grubby --update-kernel=ALL --args="mem_sleep_default=deep"

# 3. Confirm I2C touchpad runtime PM is locked to 'on' and IRQs are off CPU0
cat /sys/bus/i2c/devices/i2c-ELAN0676:00/power/control
grep -iE 'i2c_designware|ELAN0676' /proc/interrupts
```

### 3. Docker, Kubernetes (`kind`), & Sysctls
```bash
systemctl is-active docker
docker ps
kubectl version --client
kind version
sysctl fs.inotify.max_user_watches fs.inotify.max_user_instances
```

### 4. Obsidian ↔ AnkiConnect Integration
- Keep Anki closed (or open) and click the **Flashcards** ribbon icon in Obsidian on a note under `~/Notes/Study/Anki/` (e.g., `Learning System.md`).
- Confirm AnkiConnect responds on `127.0.0.1:8765`:
  ```bash
  curl -s http://127.0.0.1:8765 -X POST -d '{"action":"version","version":6}'
  ```

### 5. LocalSend Firewall & iPhone Diagnostics
```bash
# Confirm firewalld allows LocalSend port 53317
sudo firewall-cmd --list-ports

# Test iPhone battery script (after trusting computer on iPhone)
idevicepair pair
~/iphone-battery.sh
```
