local home = os.getenv("HOME")
local config_dir = home .. "/.config/sketchybar"

sbar.exec("cd " .. config_dir .. "/helpers && make")
