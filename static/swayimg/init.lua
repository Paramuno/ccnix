-- ~/.config/swayimg/init.lua

-- ==============================================================
-- Swayimg: Vim-Like Keybindings & Wayland Integration
-- ==============================================================

-- Make status text highly visible
swayimg.text.set_size(24)
swayimg.text.set_foreground(0xff00ff00) -- Opaque green

-- --------------------------------------------------------------
-- 1. Panning Operations (h, j, k, l)
-- --------------------------------------------------------------
-- These functions fetch the current window and image dimensions, 
-- and shift the absolute position by exactly 10% of the screen.

swayimg.viewer.on_key("h", function()
    local w, _ = unpack(swayimg.get_window_size())
    local x, y = unpack(swayimg.viewer.get_position())
    swayimg.viewer.set_abs_position(math.floor(x - w / 10), y)
end)

swayimg.viewer.on_key("l", function()
    local w, _ = unpack(swayimg.get_window_size())
    local x, y = unpack(swayimg.viewer.get_position())
    swayimg.viewer.set_abs_position(math.floor(x + w / 10), y)
end)

swayimg.viewer.on_key("k", function()
    local _, h = unpack(swayimg.get_window_size())
    local x, y = unpack(swayimg.viewer.get_position())
    swayimg.viewer.set_abs_position(x, math.floor(y - h / 10))
end)

swayimg.viewer.on_key("j", function()
    local _, h = unpack(swayimg.get_window_size())
    local x, y = unpack(swayimg.viewer.get_position())
    swayimg.viewer.set_abs_position(x, math.floor(y + h / 10))
end)


-- --------------------------------------------------------------
-- 2. Zooming Operations (=, -)
-- --------------------------------------------------------------
-- Calculates the exact center of the current window so that keyboard
-- zooming scales proportionally from the middle of the screen.

swayimg.viewer.on_key("=", function()
    local w, h = unpack(swayimg.get_window_size())
    local scale = swayimg.viewer.get_scale()
    scale = scale + scale / 10
    swayimg.viewer.set_abs_scale(scale, math.floor(w / 2), math.floor(h / 2))
end)

swayimg.viewer.on_key("-", function()
    local w, h = unpack(swayimg.get_window_size())
    local scale = swayimg.viewer.get_scale()
    scale = scale - scale / 10
    swayimg.viewer.set_abs_scale(scale, math.floor(w / 2), math.floor(h / 2))
end)


-- --------------------------------------------------------------
-- 3. File Operations & Wayland Clipboard
-- --------------------------------------------------------------
-- These use Lua's native OS execution to pipe information directly 
-- into wl-clipboard, making operations incredibly fast in a Wayland environment.

-- Yank (copy) the absolute file path
swayimg.slideshow.on_key("y", function()
    local image = swayimg.slideshow.current_image()
    if image and image['path'] then
        os.execute("echo -n '" .. image['path'] .. "' | wl-copy")
        swayimg.set_status("Path yanked: " .. image['path'])
    end
end)

-- Yank (copy) the actual image data (Shift+Y)
swayimg.slideshow.on_key("Y", function()
    local image = swayimg.slideshow.current_image()
    if image and image['path'] then
        os.execute("wl-copy < '" .. image['path'] .. "'")
        swayimg.set_status("Image data copied to clipboard")
    end
end)

-- Delete the current file (x)
swayimg.slideshow.on_key("x", function()
    local image = swayimg.slideshow.current_image()
    if image and image['path'] then
        os.remove(image['path'])
        swayimg.set_status("Deleted: " .. image['path'])
    end
end)
