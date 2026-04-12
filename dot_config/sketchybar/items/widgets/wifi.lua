local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local helpers = require("helpers")

local network_interface = helpers.active_network_interface()
local network_load_bin = helpers.paths.network_load
local wifi_popup_script = helpers.paths.wifi_popup

local function shell_quote(value)
    return helpers.shell_quote(value)
end

local function start_network_updates()
    if not helpers.has.network_load then return end
    sbar.exec("killall network_load >/dev/null; "
        .. shell_quote(network_load_bin)
        .. " " .. network_interface .. " network_update 2.0")
end

local function refresh_network_interface()
    local detected = helpers.active_network_interface()
    if detected ~= "" and detected ~= network_interface then
        network_interface = detected
        start_network_updates()
    end
    return network_interface
end

-- Execute the event provider binary which provides the event "network_update"
-- for the active network interface, which is fired every 2.0 seconds.
start_network_updates()

local wifi_up = sbar.add("item", "widgets.wifi1", {
    position = "right",
    click_script = wifi_popup_script,
    padding_left = -5,
    width = 0,
    icon = {
        padding_right = 0,
        font = {
            style = settings.font.style_map["Bold"],
            size = 9.0,
        },
        string = icons.wifi.upload,
    },
    label = {
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 9.0,
        },
        color = colors.red,
        string = "??? Bps",
    },
    y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
    position = "right",
    click_script = wifi_popup_script,
    padding_left = -5,
    icon = {
        padding_right = 0,
        font = {
            style = settings.font.style_map["Bold"],
            size = 9.0,
        },
        string = icons.wifi.download,
    },
    label = {
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 9.0,
        },
        color = colors.blue,
        string = "??? Bps",
    },
    y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
    position = "right",
    click_script = wifi_popup_script,
    label = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
    wifi.name,
    wifi_up.name,
    wifi_down.name
}, {
    background = { color = colors.bg1 },
    popup = { align = "center", height = 30 }
})

local ssid = sbar.add("item", "widgets.wifi.ssid", {
    position = "popup." .. wifi_bracket.name,
    icon = {
        font = {
            style = settings.font.style_map["Bold"]
        },
        string = icons.wifi.router,
    },
    width = 250,
    align = "center",
    label = {
        font = {
            size = 15,
            style = settings.font.style_map["Bold"]
        },
        max_chars = 18,
        string = "????????????",
    },
    background = {
        height = 2,
        color = colors.grey,
        y_offset = -15
    }
})

local networks = sbar.add("item", "widgets.wifi.networks", {
    position = "popup." .. wifi_bracket.name,
    icon = {
        align = "left",
        string = "Networks:",
        width = 125,
    },
    label = {
        string = "Open Wi-Fi",
        width = 125,
        align = "right",
        color = colors.grey,
    },
    click_script = wifi_popup_script,
})

sbar.add("item", { position = "right", width = settings.group_paddings })

wifi_up:subscribe("network_update", function(env)
    local up_color = (env.upload == "000 Bps") and colors.grey or colors.red
    local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
    wifi_up:set({
        icon = { color = up_color },
        label = {
            string = env.upload,
            color = up_color
        }
    })
    wifi_down:set({
        icon = { color = down_color },
        label = {
            string = env.download,
            color = down_color
        }
    })
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
    local iface = refresh_network_interface()
    sbar.exec("ipconfig getifaddr " .. iface, function(ip_address)
        local connected = not (ip_address == "")
        wifi:set({
            icon = {
                string = connected and icons.wifi.connected or icons.wifi.disconnected,
                color = connected and colors.white or colors.red,
            },
        })
    end)
end)

local function hide_details()
    wifi_bracket:set({ popup = { drawing = false } })
end

wifi_up:subscribe("mouse.exited.global", hide_details)
wifi_down:subscribe("mouse.exited.global", hide_details)
wifi:subscribe("mouse.exited.global", hide_details)
