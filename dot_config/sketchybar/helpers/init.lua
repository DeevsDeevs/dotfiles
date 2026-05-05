local M = {}

M.home = os.getenv("HOME") or "/Users/deevs"
M.config_dir = os.getenv("CONFIG_DIR")
if not M.config_dir or M.config_dir == "" then
    M.config_dir = M.home .. "/.config/sketchybar"
end

function M.trim(value)
    if not value then return "" end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function M.detached(command)
    -- sbar.exec children inherit sketchybar_lua's stdio, lock fd, and other
    -- implementation fds. Long-running helpers must not keep those fds open
    -- after reloads, or they can look like leaked/orphaned processes.
    return "( for fd in $(jot 253 3); do eval \"exec ${fd}>&-\" 2>/dev/null || true; done; exec </dev/null >/dev/null 2>&1 " .. command .. " ) &"
end

function M.file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function M.executable_exists(path)
    return M.file_exists(path)
end

function M.read_command(command)
    local handle = io.popen(command, "r")
    if not handle then return "" end
    local output = handle:read("*a") or ""
    handle:close()
    return output
end

M.paths = {
    audio_devices = M.config_dir .. "/helpers/audio_devices/bin/audio_devices",
    cpu_load = M.config_dir .. "/helpers/event_providers/cpu_load/bin/cpu_load",
    menus = M.config_dir .. "/helpers/menus/bin/menus",
    network_interface = M.config_dir .. "/helpers/network_interface.sh",
    network_load = M.config_dir .. "/helpers/event_providers/network_load/bin/network_load",
    wifi_popup = M.config_dir .. "/helpers/wifi_popup.sh",
    volume_popup = M.config_dir .. "/helpers/volume_popup.sh",
}

M.has = {}
for name, path in pairs(M.paths) do
    M.has[name] = M.executable_exists(path)
end

function M.active_network_interface()
    if M.has.network_interface then
        local interface = M.trim(M.read_command(M.shell_quote(M.paths.network_interface)))
        if interface ~= "" then
            return interface
        end
    end
    return "en0"
end

_G.helpers = M

return M
