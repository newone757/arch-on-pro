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

### Skip — provided by Omarchy/the fork, or removed in 4.0
- **Removed in 4.0 (do not reinstall):** `walker`, `elephant*` (old launcher stack) — 4.0's
  launcher is Quickshell. Also gone at the system level: mako, swaybg, hyprlock/hypridle, swayosd.
- **Comes with Omarchy/fork:** `omarchy-chromium-bin`, `omarchy-nvim`, `aether`,
  `xdg-terminal-exec`, `hyprshade`, `wayfreeze-git`, `hyprland-preview-share-picker-git`, `yay`.
- **Pulled as dependencies:** the `python-*`, `*-targeting-pack`, `aspnet-*` entries.

### Reinstall — your actual apps (the ones worth not forgetting)
- **Browsers:** `brave-bin`, `zen-browser-twilight-bin` (+ re-run `bin/setup-brave`, `bin/setup-zen`)
- **Terminal:** `ghostty-git` (+ `ghostty-shell-integration-git`, `ghostty-terminfo-git`)
- **Editors/notes:** `typora`, `obsidian`, `ttf-ia-writer`
- **Media/graphics:** `obs-studio-git`, `pinta-git`, `miniaturo-git`
- **Files/sharing:** `localsend-bin`, `dropbox` (native .desktop was present)
- **Dev:** `claude-code`, `opencode`, `bun-prebuilt`, `mise`, the `dotnet-sdk/runtime-10.0-bin` stack, `pandoc-bin`
- **Input/hardware (also have setup scripts in `../bin/`):** `titdb-git`, `input-remapper-git`,
  `waypaper`, `papirus-folders`, `blueberry`, `gnome-bluetooth`, `tzupdate`, `ufw-docker`
- **Fonts/icons:** `ttf-ia-writer`, `yaru-icon-theme`

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
