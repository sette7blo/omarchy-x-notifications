#!/usr/bin/env bash
# Reverse everything install.sh wrote. Leaves the plugin directory behind.

set -euo pipefail

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="x-notifications"
HYPRLAND_LUA="$HOME/.config/hypr/hyprland.lua"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SYSTEMD_UNIT="x-notifications-watcher.service"
BEGIN="-- BEGIN $PLUGIN_NAME plugin (managed by install.sh)"
END="-- END $PLUGIN_NAME plugin"

# shellcheck source=bin/_common.sh
source "$PLUGIN_DIR/bin/_common.sh"

log() { printf '[x-notifications] %s\n' "$*"; }

remove_hyprland_requires() {
  [[ -f $HYPRLAND_LUA ]] || return 0
  grep -qF -- "$BEGIN" "$HYPRLAND_LUA" || return 0
  log "removing plugin block from $HYPRLAND_LUA"
  local tmp; tmp=$(mktemp)
  awk -v b="$BEGIN" -v e="$END" '
    index($0, b) == 1 { skip = 1; next }
    skip && index($0, e) == 1 { skip = 0; next }
    !skip
  ' "$HYPRLAND_LUA" > "$tmp"
  mv "$tmp" "$HYPRLAND_LUA"
}

remove_systemd_unit() {
  systemctl --user disable --now "$SYSTEMD_UNIT" 2>/dev/null || true
  rm -f "$SYSTEMD_DIR/$SYSTEMD_UNIT"
  systemctl --user daemon-reload
  log "systemd unit removed"
}

disable_widget() {
  omarchy plugin disable "$PLUGIN_NAME" 2>&1 | sed 's/^/[x-notifications] /' || true
}

kill_webapp() {
  local addr
  addr=$(hyprctl clients -j 2>/dev/null | \
    jq -r --arg re "$CLASS_RE" 'first(.[] | select(.class | test($re)) | .address) // empty')
  [[ -n $addr ]] || return 0
  hyprctl dispatch "hl.dsp.window.close({window=\"address:$addr\"})" >/dev/null || true
  log "closed running X webapp window"
}

remove_hyprland_requires
remove_systemd_unit
disable_widget
kill_webapp
hyprctl reload >/dev/null && log "reloaded hyprland config"
log "done. Plugin dir still at $PLUGIN_DIR — delete manually to fully wipe."
