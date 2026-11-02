# x-notifications — Omarchy plugin

A bar widget that shows the unread X.com notification count and toggles a
hidden X web app on click. No X API, no paid tier — the count is scraped
from the DOM by a small browser extension that prefixes the webapp window
title with `(N) ` so the shell can read it out of `hyprctl clients`.

## Requirements

- Omarchy (Hyprland + QuickShell bar).
- A Chromium-based default browser: Brave, Chrome, Chromium, Edge, Opera,
  Vivaldi, or Helium. Firefox is not supported (no `--app=` with stable
  WM_CLASS, no unsigned extensions on release channel).

## Install

```sh
omarchy plugin add https://github.com/sette7blo/omarchy-x-notifications --enable
~/.config/omarchy/plugins/x-notifications/install.sh
```

The first command is the standard Omarchy flow: clone into
`~/.config/omarchy/plugins/x-notifications` and register the bar widget.
The second command does the extras `omarchy plugin add` doesn't handle.
Both commands are idempotent, so re-running them is safe.

`install.sh`:

1. Verifies a Chromium-based default browser.
2. Appends `require()` lines for `hypr.lua` and `autostart.lua` to
   `~/.config/hypr/hyprland.lua`, guarded by sentinel comments.
3. Installs and enables the user systemd service that hides the popover
   when focus leaves it.
4. Enables the bar widget via `omarchy plugin enable` (skipped if you
   already passed `--enable` above).
5. Launches the hidden X webapp so you don't have to log out.

## Uninstall

```sh
~/.config/omarchy/plugins/x-notifications/uninstall.sh
```

Reverses each install step. Does not delete the plugin directory.

## How it works

- `extension/` — Chrome MV3 extension loaded via `--load-extension=`. Polls
  the DOM for the bell count every 1.5s and prefixes `document.title`.
- `BarWidget.qml` — Omarchy QML widget. Polls `bin/x-notifications` every
  30s and spawns `bin/x-notifications-toggle` on click.
- `bin/x-notifications` — reads the title out of `hyprctl clients -j` and
  emits Waybar-style JSON.
- `bin/x-notifications-toggle` — toggles `special:xnotif`, launching the
  webapp first if needed.
- `bin/x-notifications-watcher` — listens on the Hyprland event socket and
  auto-hides the popover when focus moves away.
- `hypr.lua` — window rule, blur/dim overrides, special_fallthrough.
- `autostart.lua` — launches the webapp at login.

## Customization

Icon and badge glyphs live in `bin/x-notifications`. The matched WM_CLASS
is anchored on the suffix `-x.com__home-Default`, which covers every
Chromium derivative; adjust `CLASS_RE` in `bin/_common.sh` if your browser
produces something different.
