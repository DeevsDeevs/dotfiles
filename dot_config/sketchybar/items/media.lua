local icons = require("icons")
local colors = require("colors")
local helpers = require("helpers")

local whitelist = {
    ["com.spotify.client"] = true,
    ["com.apple.Music"] = true,
}

local media_cover = sbar.add("item", "media.cover", {
    position = "right",
    background = {
        color = colors.transparent,
    },
    label = { drawing = false },
    icon = { drawing = false },
    drawing = false,
    updates = true,
    popup = {
        align = "center",
        horizontal = true,
    }
})

local media_artist = sbar.add("item", "media.artist", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    width = 0,
    icon = { drawing = false },
    label = {
        width = 0,
        font = { size = 9 },
        color = colors.with_alpha(colors.white, 0.6),
        max_chars = 18,
        y_offset = 6,
    },
})

local media_title = sbar.add("item", "media.title", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    icon = { drawing = false },
    label = {
        font = { size = 11 },
        width = 0,
        max_chars = 16,
        y_offset = -5,
    },
})

-- Popup controls
sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.back },
    label = { drawing = false },
    click_script = "media-control previous-track",
})
sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.play_pause },
    label = { drawing = false },
    click_script = "media-control toggle-play-pause",
})
sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.forward },
    label = { drawing = false },
    click_script = "media-control next-track",
})

local interrupt = 0
local function animate_detail(detail)
    if (not detail) then interrupt = interrupt - 1 end
    if interrupt > 0 and (not detail) then return end

    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
end

-- Mouse interactions
media_cover:subscribe("mouse.entered", function(env)
    interrupt = interrupt + 1
    animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(env)
    animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(env)
    media_cover:set({ popup = { drawing = false } })
end)

-- media_stream.sh follows `media-control stream` and fires this event with
-- small env vars only; artwork arrives as a decoded file path. Keeps the
-- ~300KB base64 payloads out of the lua<->sketchybar bridge (deadlocks).
sbar.add("event", "media_change")

local function start_media_stream()
    if not helpers.has.media_stream then return end
    sbar.exec("pkill -f 'sketchybar/helpers/media_stream.sh' >/dev/null 2>&1;"
        .. " pkill -f 'media-control stream' >/dev/null 2>&1; "
        .. helpers.detached(helpers.shell_quote(helpers.paths.media_stream)))
end

start_media_stream()

media_cover:subscribe("system_woke", function()
    start_media_stream()
end)

media_cover:subscribe("media_change", function(env)
    local drawing = env.PLAYING == "true" and whitelist[env.APP] or false

    media_artist:set({ drawing = drawing, label = env.ARTIST })
    media_title:set({ drawing = drawing, label = env.TITLE })

    if not drawing then
        media_cover:set({ drawing = false, popup = { drawing = false } })
        return
    end

    if env.ART_PATH and helpers.file_exists(env.ART_PATH) then
        media_cover:set({
            drawing = true,
            background = {
                image = {
                    string = env.ART_PATH,
                    scale = 0.05,
                },
                color = colors.transparent,
            }
        })
    else
        media_cover:set({ drawing = true })
    end
end)
