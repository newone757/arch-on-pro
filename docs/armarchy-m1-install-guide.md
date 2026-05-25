# Omarchy on Apple Silicon (M1/M2) — Installation Guide

> Community-maintained notes for getting [Omarchy](https://github.com/basecamp/omarchy) (Arch Linux + Hyprland) running on Apple Silicon via [Asahi Alarm](https://asahi-alarm.org/) and the [jondkinney/armarchy](https://github.com/jondkinney/armarchy) fork. Based on real installation experience — May 2026.

---

## Background & Repo Situation

The original `omarchy-mac` repo (`malik-na/omarchy-mac`) has been taken down. As of May 2026, the actively maintained path for bare-metal Apple Silicon is:

- **Repo:** [`jondkinney/armarchy`](https://github.com/jondkinney/armarchy) (branch: `amarchy-3-x`)
- **Upstream PR:** [basecamp/omarchy#1897](https://github.com/basecamp/omarchy/pull/1897) — adds full aarch64 support to Omarchy 3.x
- This PR is open and actively developed; it has not yet been merged into mainline Omarchy

---

## Prerequisites

- Apple Silicon Mac (M1/M2 family)
- At least 50GB free on internal SSD (100GB recommended)
- A recent Time Machine backup
- Internet connection (ethernet preferred for stability; WiFi works but YMMV)

---

## Step 1: Install Asahi Alarm

Run this from macOS Terminal:

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

**Important:** When prompted, select **Asahi Arch Minimal** — not the full desktop option.

When the installer finishes it will prompt you to reboot into Arch. Log in as `root` (password: `root`).

---

## Step 2: Initial Arch Setup

```bash
# Configure WiFi if needed — use nmtui for a guided interface
nmtui
# Navigate to "Activate a connection", select your network, enter password
# If it shows an error after activation, reboot and try again

# Update packages
pacman -Syu

# Install essentials
pacman -S --needed sudo git base-devel wget
```

---

## Step 3: Create a Regular User

```bash
useradd -m -G wheel YOUR_USERNAME
passwd YOUR_USERNAME

# Enable sudo for wheel group
EDITOR=nano visudo
# Uncomment the line: %wheel ALL=(ALL:ALL) ALL

# Switch to your new user
su - YOUR_USERNAME
```

---

## Step 4: Install yay (AUR helper)

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
```

---

## Step 5: Run the Armarchy Installer

```bash
wget -qO- https://raw.githubusercontent.com/jondkinney/armarchy/amarchy-3-x/boot.sh \
  | OMARCHY_REPO=jondkinney/armarchy OMARCHY_REF=amarchy-3-x bash
```

Or via shortlink (inspect first by omitting `| bash`):

```bash
curl -fsSL hdwy.link/armarchy-3-x | bash
```

---

## Known Issues & Workarounds

These are issues encountered during installation in May 2026. The installer re-pulls the repo on each run via the curl/wget command, so **edits to scripts only persist if you re-run `bash install.sh` directly** from `~/.local/share/omarchy` rather than re-running the curl command.

### The installer overwrites your edits on re-run

After the initial clone, always retry by running the installer directly:

```bash
cd ~/.local/share/omarchy
bash install.sh
```

Never re-run the original `wget`/`curl` command after first install — it re-clones and wipes your changes.

---

### `blueberry` fails — gnome-bluetooth has no ARM build

**Symptom:** Install fails early with a dependency error on `blueberry`.

**Fix:** Check the install log for the exact missing dependencies and install them manually, then re-run the installer:

```bash
tail -f ~/.local/share/omarchy/install.log
# Note the specific packages that failed, install them with pacman, then retry
bash install.sh
```

---

### `lua5.1` not found

**Symptom:**
```
sh: line 1: /usr/bin/lua5.1: No such file or directory
```

**Fix:**
```bash
sudo pacman -S lua51
```

---

### `omarchy-nvim` fails — wrong path in install script

**Symptom:**
```
omarchy-nvim.sh: line 45: cd: omarchy-pkgs/pkgbuilds/edge/omarchy-nvim: No such file or directory
```

**Cause:** The script expects `omarchy-nvim` under `pkgbuilds/edge/`, but the cloned repo places it directly under `pkgbuilds/`.

**Fix:** Edit the script and correct the path:

```bash
nano ~/.local/share/omarchy/install/arm_install_scripts/omarchy-nvim.sh
```

Find the `cd omarchy-pkgs/pkgbuilds/edge/omarchy-nvim` line and change it to:
```bash
cd omarchy-pkgs/pkgbuilds/omarchy-nvim
```

Save, then re-run `bash install.sh` from `~/.local/share/omarchy`.

---

### `signal-desktop-beta` fails — nodejs conflict

**Symptom:**
```
nodejs-lts-krypton and nodejs-lts-jod are in conflict
error: failed to prepare transaction (conflicting dependencies)
Failed to build/install 'signal-desktop-beta'
```

**Fix:** The installer has a built-in skip flag for this. Run the installer with:

```bash
SKIP_SIGNAL_DESKTOP_BETA=1 bash install.sh
```

Signal Desktop Beta can be installed manually later once you're in the desktop environment. You can also try removing the conflicting package first:

```bash
sudo pacman -Rdd --noconfirm nodejs-lts-jod
```

---

### Sudo password prompts constantly during install

The installer calls `sudo pacman` and `makepkg -si` many separate times, so it prompts repeatedly — this is not a timeout issue, it's just how the scripts are structured.

**Fix:** Temporarily enable passwordless sudo for your user via `visudo`, get through the install, then re-enable the password requirement when done:

```bash
sudo visudo
# Find the line for your user or the wheel group and add NOPASSWD:
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL
```

Remember to revert this after the install completes.

---

### Installer UI glitches / flashing text on TTY

The installer uses `gum` for its TUI, which doesn't render cleanly on the Asahi framebuffer console. This is cosmetic — the install is still running.

**Workaround:** Follow progress via the log file in a second TTY (`Ctrl+Option+F2` on MacBook):

```bash
tail -f ~/.local/share/omarchy/install.log
```

If the installer appears frozen, it may be waiting for a sudo password — try typing it and pressing Enter even if the prompt isn't visible.

---

### Mirrors slow or failing

```bash
bash fix-mirrors.sh
# then retry
sudo pacman -Syyu
```

Or manually edit `/etc/pacman.d/mirrorlist` and move a US mirror to the top:
```
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
```

---

## Post-Install

- Reboot and select the Linux entry from the bootloader
- Verify WiFi, display, keyboard, and trackpad
- Install Signal Desktop manually if you skipped it:
  ```bash
  sudo pacman -Rdd nodejs-lts-jod
  yay -S signal-desktop-beta
  ```

---

## Resources

- [jondkinney/armarchy](https://github.com/jondkinney/armarchy) — the installer repo
- [basecamp/omarchy PR #1897](https://github.com/basecamp/omarchy/pull/1897) — upstream ARM support PR, actively developed
- [Asahi Linux device support](https://asahilinux.org/fedora/#device-support)
- [Asahi Alarm](https://asahi-alarm.org/)
- [Omarchy Discord](https://discord.gg/tXFUdasqhY) — community support
- [basecamp/omarchy discussions](https://github.com/basecamp/omarchy/discussions/452) — VM and M1 install discussion thread

## Guides that helped

These both use the now-dead `malik-na/omarchy-mac` repo, but the process is the same — just swap in `jondkinney/armarchy` at the relevant steps:

- [Omarchy Mac: The Revolutionary Arch Setup for Apple Silicon](https://converter.brightcoding.dev/blog/omarchy-mac-the-revolutionary-arch-setup-for-apple-silicon)
- [YouTube walkthrough by jA0IVb3T-IM](https://www.youtube.com/watch?v=jA0IVb3T-IM)
