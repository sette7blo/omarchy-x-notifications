# Sourced by the sibling scripts.

# Chromium's --app= always ends the WM_CLASS with -x.com__home-Default,
# regardless of which brave/chrome/chromium/edge/opera/vivaldi binary ran it.
CLASS_RE='-x\.com__home-Default$'
WORKSPACE='xnotif'

PLUGIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSION_DIR="$PLUGIN_DIR/extension"
