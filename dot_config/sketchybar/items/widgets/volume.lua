local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250
local home = os.getenv("HOME") or "/Users/deevs"
local volume_popup_script = home .. "/.config/sketchybar/helpers/volume_popup.sh"
local volume_bracket

local volume_percent = sbar.add("item", "widgets.volume1", {
    position = "right",
    icon = { drawing = false },
    label = {
        string = "??%",
        padding_left = -1,
        font = { family = settings.font.numbers },
    },
    click_script = volume_popup_script,
})

local volume_icon = sbar.add("item", "widgets.volume2", {
    position = "right",
    padding_right = -1,
    icon = {
        string = icons.volume._100,
        width = 0,
        align = "left",
        color = colors.grey,
        font = {
            style = settings.font.style_map["Regular"],
            size = 14.0,
        },
    },
    label = {
        width = 25,
        align = "left",
        font = {
            style = settings.font.style_map["Regular"],
            size = 14.0,
        },
    },
    click_script = volume_popup_script,
})

volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
    volume_icon.name,
    volume_percent.name
}, {
    background = { color = colors.bg1 },
    popup = { align = "center" }
})

sbar.add("item", "widgets.volume.padding", {
    position = "right",
    width = settings.group_paddings
})

local volume_slider = sbar.add("slider", popup_width, {
    position = "popup." .. volume_bracket.name,
    slider = {
        highlight_color = colors.blue,
        background = {
            height = 6,
            corner_radius = 3,
            color = colors.bg2,
        },
        knob = {
            string = "􀀁",
            drawing = true,
        },
    },
    background = { color = colors.bg1, height = 2, y_offset = -20 },
    click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume_percent:subscribe("volume_change", function(env)
    local volume = tonumber(env.INFO)
    local icon = icons.volume._0
    if volume > 60 then
        icon = icons.volume._100
    elseif volume > 30 then
        icon = icons.volume._66
    elseif volume > 10 then
        icon = icons.volume._33
    elseif volume > 0 then
        icon = icons.volume._10
    end

    local lead = ""
    if volume < 10 then
        lead = "0"
    end

    volume_icon:set({ label = icon })
    volume_percent:set({ label = lead .. volume .. "%" })
    volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
    local drawing = volume_bracket:query().popup.drawing == "on"
    if not drawing then return end
    volume_bracket:set({ popup = { drawing = false } })
    sbar.remove('/volume.device\\.*/')
end

local function volume_scroll(env)
    local delta = env.INFO.delta
    if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end

    sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)
