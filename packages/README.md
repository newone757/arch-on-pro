# Package + app state snapshot

Captured on **Omarchy 3.5.1 (armarchy fork), MBP 16" M1** — a reference for rebuilding
after a clean Omarchy 4.0 install (see `../docs/omarchy-4-migration.md`).

- `pacman-explicit.txt` — all explicitly-installed repo packages (`pacman -Qqe`)
- `aur.txt` — AUR / foreign packages (`pacman -Qqm`)
- Webapp shortcuts live in `../local/share/applications/*.desktop` (+ `icons/`)

## Do NOT blindly `pacman -S` the whole list

You'll be on a **different base** (mac fork, Omarchy 4.0). Reinstalling the full set will
drag in things 4.0 provides itself, things it **removed**, and things that are just deps.
Restore *selectively*.

The "you added" lists below were derived by diffing installed packages against
Omarchy's own default manifests (`~/.local/share/omarchy/install/*.packages`).
⚠️ Caveat: packages Omarchy installs via **scripts** (not `.packages`) look like
user additions but aren't — confirmed preinstalled: **`zen-browser-twilight-bin`,
`ghostty-git` (+integration/terminfo), `walker`** (see `install/arm_install_scripts/`).

### Skip — Omarchy defaults / base / removed in 4.0 (do NOT reinstall)
- **Preinstalled by Omarchy (AUR):** `zen-browser-twilight-bin`, `ghostty-git`+integration+terminfo,
  `walker`, `typora`, `obs-studio-git`, `localsend-bin`, `mise`, `opencode`, `claude-code`,
  `pinta-git`, `aether`, `elephant*`, `blueberry`, `hyprshade`, `ttf-ia-writer`, `yaru-icon-theme`,
  `wayfreeze-git`, `xdg-terminal-exec`, `tzupdate`, `ufw-docker`, `omarchy-chromium-bin`,
  `omarchy-nvim`, `yay`, `hyprland-preview-share-picker-git`.
- **Removed in 4.0:** `walker`/`elephant*` (Quickshell launcher now); also mako, swaybg,
  hyprlock/hypridle, swayosd at the system level.
- **Asahi/Arch base + deps (fork installs these):** `linux-asahi`, `m1n1`, `uboot-asahi`,
  `asahi-*`, `*-keyring`, `grub`, `greetd`, `networkmanager`, `openssh`, `sudo`, `neovim`,
  `nodejs`/`npm`, `cmake`, and lib deps (`asio`, `mbedtls`, `simde`, `python-imageio-ffmpeg`,
  `electron41-bin`, `*-targeting-pack`, etc).

### Reinstall — YOUR additions (confirmed via diff)
- **Browser:** `brave-bin` (+ re-run `bin/setup-brave`)  *(zen is preinstalled — skip)*
- **Photo/media:** `darktable` *(maybe drop — you stopped using it)*, `vlc`
- **Dev:** `dotnet-sdk/runtime/host/targeting-pack-10.0-bin`, `aspnet-runtime/targeting-pack-10.0-bin`,
  `bun-prebuilt`, `pandoc-bin`
- **Networking/util:** `tailscale`, `duf`, `powertop`, `xclip`
- **Input/hardware/theming (tied to `../bin/setup-*`):** `titdb-git`, `input-remapper-git`,
  `waypaper`, `papirus-folders`, `papirus-icon-theme`, `gnome-bluetooth`, `iio-sensor-proxy`
- **Misc:** `miniaturo-git`

### Already captured elsewhere (don't need manual reinstall reasoning)
- **EasyEffects speaker EQ:** `easyeffects` + `calf` + `mda.lv2` + `rnnoise` + **`rtkit`** → `bin/setup-easyeffects` + presets.
  `rtkit` isn't EasyEffects-specific — it's baseline PipeWire infrastructure (grants
  audio threads realtime scheduling so they aren't starved by other CPU load) that
  was simply missing from this fresh 4.0 install entirely. Without it, PipeWire/
  WirePlumber/EasyEffects threads all run at normal priority, causing audible pops
  under load (confirmed via `ps -eLo pid,tid,rtprio,comm` — none had `rtprio` set;
  `journalctl -u rtkit-daemon` showed it granting RT priority successfully once
  installed). Bundled into `setup-easyeffects` since that's what surfaced the bug,
  but it benefits the whole audio stack regardless of whether EasyEffects is used.
- **Spotify:** webapp, not a package → `../local/share/applications/Spotify.desktop`
- **Windows VM:** `freerdp` + `openbsd-netcat` + Docker image `dockurr/windows` → `config/windows/` + README
- **Widevine DRM:** `widevine` → part of `bin/setup-brave`

### Webapps
Only the webapps **you added** are tracked (Discord, GitHub, Spotify, YouTube, Lightroom CC)
— Omarchy's stock webapps (ChatGPT, Figma, Google apps, WhatsApp, X, Zoom, HEY, …) come
back on their own with a fresh 4.0 install. These use `omarchy-launch-webapp` (a core
Omarchy command present in 4.0). Copy them + `icons/` into `~/.local/share/applications/`,
run `update-desktop-database ~/.local/share/applications`, and they'll appear in the launcher.

## Regenerate this snapshot before the wipe
```bash
pacman -Qqe > packages/pacman-explicit.txt
pacman -Qqm > packages/aur.txt
```
