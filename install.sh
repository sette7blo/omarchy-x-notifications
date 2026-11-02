#!/usr/bin/env bash
# Idempotent installer for the x-notifications Omarchy plugin.

set -euo pipefail

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="x-notifications"
HYPRLAND_LUA="$HOME/.config/hypr/hyprland.lua"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SYSTEMD_UNIT="x-notifications-watcher.service"
BEGIN="-- BEGIN $PLUGIN_NAME plugin (managed by install.sh)"
END="-- END $PLUGIN_NAME plugin"

log() { printf '[x-notifications] %s\n' "$*"; }

check_browser() {
  local b
  b=$(omarchy-cmd-default-browser 2>/dev/null || true)
  case "$b" in
    brave*|google-chrome*|chromium*|microsoft-edge*|opera*|vivaldi*|helium*)
      log "default browser: $b (ok)" ;;
    *)
      log "WARNING: default browser '$b' is not Chromium-based. The widget"
      log "         will show the X icon but no live count. Install a Chromium"
      log "         browser (brave/chrome/chromium/edge/opera/vivaldi) and set it as default." ;;
  esac
}

install_hyprland_requires() {
  [[ -f $HYPRLAND_LUA ]] || { log "ERROR: $HYPRLAND_LUA not found"; exit 1; }
  if grep -qF -- "$BEGIN" "$HYPRLAND_LUA"; then
    log "hyprland.lua already wired (skip)"
    return
  fi
  log "appending plugin requires to $HYPRLAND_LUA"
  cat >> "$HYPRLAND_LUA" <<EOF

$BEGIN
require("omarchy.plugins.$PLUGIN_NAME.autostart")
require("omarchy.plugins.$PLUGIN_NAME.hypr")
$END
EOF
}

install_systemd_unit() {
  mkdir -p "$SYSTEMD_DIR"
  local target="$SYSTEMD_DIR/$SYSTEMD_UNIT" src="$PLUGIN_DIR/systemd/$SYSTEMD_UNIT"
  if [[ ! -L $target || "$(readlink "$target")" != "$src" ]]; then
    rm -f "$target"
    ln -s "$src" "$target"
    log "symlinked $target -> $src"
  fi
  systemctl --user daemon-reload
  systemctl --user enable --now "$SYSTEMD_UNIT"
  log "systemd unit enabled"
}

enable_widget() {
  if omarchy plugin list --json 2>/dev/null | \
     jq -e --arg id "$PLUGIN_NAME" '.[] | select(.id == $id) | .enabled' >/dev/null; then
    log "widget already enabled (skip)"
    return
  fi
  omarchy plugin enable "$PLUGIN_NAME" right 2>&1 | sed 's/^/[x-notifications] /'
}

launch_webapp_now() {
  if hyprctl clients -j 2>/dev/null | \
     jq -e '.[] | select(.class | test("-x\\.com__home-Default$"))' >/dev/null; then
    return
  fi
  log "launching X webapp now so you don't need to log out"
  "$PLUGIN_DIR/bin/x-notifications-toggle" >/dev/null &
  disown
}

for dep in jq socat hyprctl; do
  command -v "$dep" >/dev/null || { log "ERROR: missing dependency: $dep"; exit 1; }
done

log "plugin dir: $PLUGIN_DIR"
check_browser
install_hyprland_requires
install_systemd_unit
enable_widget
hyprctl reload >/dev/null && log "reloaded hyprland config"
launch_webapp_now
log "done. Left-click the 𝕏 widget to open the X popover."
