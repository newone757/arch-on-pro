# omarchy-shell: cloned/third-party bar plugins fail to load

**Component:** Omarchy shell (`/usr/share/omarchy/shell/shell.qml`), `kind: "bar"` plugins
**Found:** 2026-08-22, trying to restyle the bar as two rounded "pill" groups
(left/right) instead of one full-width surface, via `omarchy plugin clone omarchy.bar`

## Symptom

`omarchy plugin clone omarchy.bar` clones fine and correctly points
`shell.json`'s `bar.id` at the new plugin (`lonnie.bar` here). But the cloned
bar never renders — no bar at all, Hyprland just lets windows use the full
screen height. This happens even with a **byte-for-byte unedited** copy of
the pristine `Bar.qml` (confirmed by testing before making any style changes),
so it's not something a plugin author can code around — the clone-and-switch
path itself is broken for `kind: "bar"` plugins.

Console (`quickshell -n -p /usr/share/omarchy/shell` run directly, not as a
service, to see stderr):

```
WARN scene: file:///home/lonnie/.config/omarchy/plugins/lonnie.bar/Bar.qml[15:3]: Required property omarchyPath was not initialized
WARN scene: file:///home/lonnie/.config/omarchy/plugins/lonnie.bar/Bar.qml[17:3]: Required property barWidgetRegistry was not initialized
WARN scene: file:///home/lonnie/.config/omarchy/plugins/lonnie.bar/Bar.qml[22:3]: Required property barConfig was not initialized
WARN scene: @shell.qml[256:-1]: ReferenceError: errorString is not defined
```

## Root cause

`Bar.qml` declares its host-injected properties as `required property`:

```qml
required property string omarchyPath
required property var barWidgetRegistry
required property var barConfig
```

`shell.qml` has two different loading paths for a bar, and only one of them
satisfies `required property` correctly:

- **Built-in default bar** — `defaultBarComponent` (`shell.qml` ~line 226) binds
  all three properties *inline*, as part of the `Component { Bar { ... } }`
  declaration itself, so they're set at construction time:
  ```qml
  Component {
    id: defaultBarComponent
    Bar {
      omarchyPath: shell.omarchyPath
      barWidgetRegistry: shell.barWidgetRegistry
      barConfig: shell.barConfig
      shell: shell
      manifest: shell.barManifestFor(shell.defaultBarId)
    }
  }
  ```
- **Any plugin-sourced bar** (cloned or third-party) — `pluginBarLoader` is a
  `Loader` with `source: shell.activeBarSourceUrl`, `asynchronous: true`. The
  properties are only assigned *after* load completes, in `onLoaded:
  shell.configureBar(item, ...)`, via plain JS assignment (`configureBar()`,
  ~line 214):
  ```qml
  function configureBar(target, manifest) {
    if (!target) return
    if ("omarchyPath" in target) target.omarchyPath = shell.omarchyPath
    ...
  }
  ```
  QML's `required property` contract must be satisfied at component
  construction — a URL-Loader instantiates the item first and only then runs
  `onLoaded`, which is too late. The component fails to construct, the Loader
  ends up in `Loader.Error` status, and no bar renders.

A second, independent bug masks the real error: `pluginBarLoader`'s
`onStatusChanged` handler (`shell.qml:256`) tries to log the failure reason
via a bare `errorString()` call that isn't defined in scope, throwing its own
`ReferenceError` instead of printing anything useful. Wasted real debugging
time here since the actual `required property` warnings were easy to
misread as harmless startup-order noise — they're not, they're the actual
failure.

## Practical impact

Any bar customization that goes beyond what `shell.toml`/`shell.json`
already expose (see `docs/omarchy-4-migration.md` bar-height and
notch-alignment sections) requires a custom `kind: "bar"` plugin, and that
entire path is currently non-functional. Confirmed on Quickshell
`quickshell-git`, rebuilt against Qt 6.11.2 (see main migration doc's
first-boot fix) — not yet checked against an unpatched/non-`-git` build.

## Status / workaround

Not fixed. Reverted `shell.json`'s `bar.id` back to `"omarchy.bar"` (the
working default). The pill-styled `Bar.qml` (two independent rounded
left/right groups, transparent panel background, mirroring the old 3.5.1
Waybar `.modules-left`/`.modules-right` CSS look) is saved, untested-live, at
`~/.config/omarchy/plugins/lonnie.bar/Bar.qml` — ready to try again once this
is fixed upstream, or on a version bump. Only real workaround right now is
patching `/usr/share/omarchy/shell/plugins/bar/Bar.qml` in place, which
`omarchy update` will silently overwrite — deliberately not done, to stay
consistent with this migration's practice of keeping all customization in
user-space config rather than system files.

## To do

- [ ] File an issue against the Omarchy shell (or the `maralcbr/omarchy-mx-mac`
      fork, whichever tracks `shell.qml`) — reference `configureBar()` vs.
      `defaultBarComponent`'s inline bindings as the fix direction: either
      make `pluginBarLoader` synchronous with properties supplied via
      `Loader.setSource`/initial properties, or drop `required` from
      `Bar.qml`'s host-injected properties in favor of sensible defaults.
- [ ] Also worth reporting the `errorString is not defined` bug in the same
      issue — trivial fix, but currently hides every plugin-bar load failure.
- [ ] Retry `omarchy plugin clone omarchy.bar` + the saved pill-styled
      `Bar.qml` after any future `omarchy update`.
