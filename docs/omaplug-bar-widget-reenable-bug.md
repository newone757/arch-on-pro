# omaplug: re-enabling a bar widget doesn't work

**Plugin:** [omaplug](https://github.com/fross100/omaplug) (Omarchy shell plugin manager)
**Found:** 2026-08-22, disabling/re-enabling `omarchy.tailscale` via omaplug's own UI

## Symptom

Disabling a bar widget (e.g. Tailscale) through omaplug's toggle works — it
disappears from the bar. Re-enabling it through the same toggle does *not*
bring it back: the switch flips to "on" in omaplug's UI, but the widget never
reappears in the bar, and clicking the toggle again does nothing further. The
UI is now permanently out of sync with reality (shows enabled, isn't).

`omarchy-shell shell rescanPlugins` does not fix it. A full `omarchy restart
shell` likely would (untested — fixed by editing `shell.json` directly
instead), but shouldn't be necessary for something this small.

## Root cause

Omarchy's official CLI uses **two different underlying shell IPC calls** for
enable vs. disable, and only one of them knows how to place a widget back
into the bar layout:

- `omarchy-plugin-disable` (`/usr/share/omarchy/bin/omarchy-plugin-disable`)
  calls `omarchy-shell shell setPluginEnabled <id> false` — simple, just
  removes the entry from `shell.json`'s bar layout array.
- `omarchy-plugin-enable` (`/usr/share/omarchy/bin/omarchy-plugin-enable`)
  calls a **different** method, `omarchy-shell shell enablePlugin <id>
  <placement>` — because re-inserting a bar widget requires knowing *where*
  (section/index/`--before`/`--after`). The CLI script computes this
  placement info explicitly before calling it.

Omaplug's toggle switch (`Panel.qml`, `setPluginEnabled()` around line 855)
calls the same generic function for **both** directions:

```qml
function setPluginEnabled(id, value) {
  var reg = root.registry
  if (!reg || typeof reg.setEnabled !== "function") return
  reg.setEnabled(id, value)
}
```

`reg.setEnabled(id, true)` is not the same call as the CLI's `enablePlugin`
and doesn't carry placement info. For non-positional plugins (panels that
aren't tied to a bar slot) this is probably fine. For anything that's a **bar
widget** — which has to be reinserted at a specific position in the layout
array — this call likely just flips some `enabled` flag without actually
re-adding the entry to `shell.json`, leaving the widget invisible and the
toggle desynced from then on.

## Practical workaround

- Use the official CLI instead, for bar widgets specifically:
  ```bash
  omarchy plugin enable omarchy.tailscale          # or --section/--index/--before/--after
  omarchy plugin disable omarchy.tailscale
  ```
- Or edit `~/.config/omarchy/shell.json`'s `bar.layout.<section>` array by
  hand and let it hot-reload (what actually fixed it live this time).
- omaplug still seems fine for browsing/installing/removing third-party
  plugins — the bug is specifically the re-enable path for **bar-widget-kind**
  plugins.

## To do

- [ ] File an issue on `github.com/fross100/omaplug` — actively maintained
      (several recent fix/security commits), likely to get addressed.
- [ ] If filing, reference `Panel.qml`'s `setPluginEnabled()` and contrast
      with `/usr/share/omarchy/bin/omarchy-plugin-enable`'s placement-aware
      `enablePlugin` call as the probable fix direction.
