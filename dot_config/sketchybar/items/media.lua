local icons = require("icons")
local colors = require("colors")

local whitelist = {
    ["Spotify"] = true,
    ["Music"] = true
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

    sbar.animate("tanh", 30, function()
        media_artist:set({ label = { width = detail and "dynamic" or 0 } })
        media_title:set({ label = { width = detail and "dynamic" or 0 } })
    end)
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

-- Poll media-control for updates
local media_watcher = sbar.add("item", "media.watcher", {
    drawing = false,
    updates = true,
    update_freq = 2,
})

local function check_file_ready(filepath)
    local f = io.open(filepath, "r")
    if f then
        local size = f:seek("end")
        f:close()
        return size and size > 0
    end
    return false
end

media_watcher:subscribe("routine", function()
    sbar.exec("media-control get", function(result)
        if type(result) ~= "table" then return end
        if not (result.playing ~= nil and result.title and result.artist and result.bundleIdentifier) then
            return
        end

        local app = "Unknown"
        if result.bundleIdentifier == "com.spotify.client" then
            app = "Spotify"
        elseif result.bundleIdentifier == "com.apple.Music" then
            app = "Music"
        end

        -- Check if app is whitelisted
        if not whitelist[app] then
            media_cover:set({ drawing = false })
            media_artist:set({ drawing = false })
            media_title:set({ drawing = false })
            return
        end

        local drawing = result.playing == true

        -- Update text widgets
        media_artist:set({ drawing = drawing, label = result.artist })
        media_title:set({ drawing = drawing, label = result.title })

        -- Handle artwork
        if result.artworkData and drawing then
            local artwork_file = "/tmp/sketchybar_album_art.jpg"

            -- Decode base64 directly via pipe (no temp file needed)
            local decode_cmd = string.format(
                "echo '%s' | base64 -d > '%s' 2>/dev/null",
                result.artworkData:gsub("'", "'\\''"),
                artwork_file
            )

            sbar.exec(decode_cmd, function()
                if not check_file_ready(artwork_file) then
                    media_cover:set({ drawing = drawing })
                    return
                end

                media_cover:set({
                    drawing = true,
                    background = {
                        image = {
                            string = artwork_file,
                            scale = 0.05,
                        },
                        color = colors.transparent,
                    }
                })
            end)
        else
            media_cover:set({ drawing = drawing })
        end

        if not drawing then
            media_cover:set({ popup = { drawing = false } })
        end
    end)
end)
