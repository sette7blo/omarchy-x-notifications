-- Autostart hook for the x-notifications plugin.
-- Launches the hidden X webapp window so the bar can poll its title.

local ext_dir = (os.getenv("HOME") or "")
  .. "/.config/omarchy/plugins/x-notifications/extension"

o.launch_on_start(
  "omarchy-launch-webapp https://x.com/home " ..
  "--disable-background-timer-throttling " ..
  "--disable-renderer-backgrounding " ..
  "--disable-backgrounding-occluded-windows " ..
  "--load-extension=" .. ext_dir
)
