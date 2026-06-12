local autocmd = vim.api.nvim_create_autocmd

-- Stop autocommenting new lines
autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Core function to extract the color and send it to Kitty via ANSI escape sequences
local function sync_kitty_bg()
  vim.defer_fn(function()
    local hl = vim.api.nvim_get_hl(0, { name = "Normal" })

    if hl and hl.bg then
      local hex = string.format("#%06x", hl.bg)

      -- \27 is the Lua representation of the ESC key.
      -- We write directly to stdout and flush it instantly to bypass Neovim's UI buffer.
      io.stdout:write("\27]11;" .. hex .. "\007")
      io.stdout:flush()
    end
  end, 0)
end

local kitty_sync_group = vim.api.nvim_create_augroup("KittySync", { clear = true })

-- in autocmds.lua
local in_zellij = vim.env.ZELLIJ ~= nil

local function force_transparent()
  if not in_zellij then
    return
  end
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "FoldColumn",
    "EndOfBuffer",
    "StatusLine",
    "StatusLineNC",
    "LineNr",
    "CursorLineNr",
    "TabLine",
    "TabLineFill",
    "TabLineSel",
    "WinBar",
    "WinBarNC",
    "VertSplit",
    "WinSeparator",
    -- snacks
    "SnacksNormal",
    "SnacksNormalNC",
    "SnacksFloat",
    "SnacksExplorerNormal",
    "SnacksPickerNormal",
    "SnacksDashboardNormal",
    -- telescope
    "TelescopeNormal",
    "TelescopePromptNormal",
    "TelescopeResultsNormal",
    "TelescopePreviewNormal",
    "TelescopeBorder",
    "TelescopePromptBorder",
    "TelescopeResultsBorder",
    "TelescopePreviewBorder",
  }
  for _, g in ipairs(groups) do
    vim.api.nvim_set_hl(0, g, { bg = "NONE", ctermbg = "NONE" })
  end
end

local transparency_group = vim.api.nvim_create_augroup("ZellijTransparency", { clear = true })

autocmd({ "ColorScheme", "VimEnter" }, {
  group = transparency_group,
  callback = force_transparent,
})

autocmd("User", {
  pattern = "VeryLazy",
  group = transparency_group,
  callback = function()
    vim.defer_fn(force_transparent, 100)
  end,
})

-- re-apply when snacks/telescope lazy-load
autocmd("User", {
  pattern = "LazyLoad",
  group = transparency_group,
  callback = force_transparent,
})

autocmd({ "ColorScheme" }, {
  group = kitty_sync_group,
  callback = function()
    if not in_zellij then
      sync_kitty_bg()
    end
  end,
})

--

-- 1. Triggers when you change the colorscheme manually
autocmd({ "ColorScheme", "UIEnter" }, {
  group = kitty_sync_group,
  callback = function()
    sync_kitty_bg()
  end,
})

-- -- 2. Triggers explicitly when LazyVim finishes its deferred startup sequence
-- autocmd("User", {
--   pattern = "*",
--   group = kitty_sync_group,
--   callback = sync_kitty_bg,
-- })

autocmd({ "User", "VimEnter" }, {
  pattern = { "VeryLazy", "*" }, -- VeryLazy matches User, * matches VimEnter
  group = kitty_sync_group,
  callback = function()
    vim.defer_fn(function()
      sync_kitty_bg()
    end, 0)
  end,
})

-- autocmd({ "VimEnter" }, {
--   pattern = { "*" }, -- VeryLazy matches User, * matches VimEnter
--   group = kitty_sync_group,
--       sync_kitty_bg()
-- })

-- Create a dedicated augroup to prevent duplicate autocmds if you reload your config
local transparent_statusline_group = vim.api.nvim_create_augroup("ForceTransparentStatusline", { clear = true })

autocmd({ "User", "UIEnter", "ColorScheme" }, {
  group = transparent_statusline_group,
  pattern = "*",
  callback = function()
    vim.cmd([[
            highlight StatusLine guibg=NONE ctermbg=NONE
            highlight StatusLineNC guibg=NONE ctermbg=NONE
        ]])
  end,
})

autocmd("VimLeavePre", {
  group = kitty_sync_group,
  callback = function()
    io.stdout:write("\27]111\007") -- OSC 111 = reset bg to kitty's configured default
    io.stdout:flush()
  end,
})

-- -- Automatically update Kitty background to match Neovim colorscheme
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   callback = function()
--     -- Get the hex color of the "Normal" highlight group
--     local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
--     if bg then
--       -- Convert decimal color to hex string
--       local hex = string.format("#%06x", bg)
--       -- Use kitty remote control to set the background
--       os.execute("kitty @ set-colors background=" .. hex)
--     end
--   end,
-- })
-- -- Ensure it runs on startup as well
-- vim.api.nvim_create_autocmd("VimLeavePre", {
--   callback = function()
--     -- Optional: Reset Kitty background to a default color when leaving Neovim
--     -- os.execute("kitty @ set-colors background=#1a1b26")
--   end,
-- })

-- -- 1. Create a master function to hold all your transparency rules
-- local function apply_fito_transparency()
--   -- Core Editor
--   vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", underline = false, bold = true })
--   vim.api.nvim_set_hl(0, "VertSplit", { bg = "NONE", underline = false, bold = true })
--   vim.api.nvim_set_hl(0, "Visual", { bg = "#753b5e", underline = false, bold = true })
--   vim.api.nvim_set_hl(0, "LineNr", { fg = "#753b5e" })
--   vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
--   vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--   -- Snacks Picker Overrides
--   vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "none" })
--   vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none" })
--   vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = "none" })
--   vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "none" })
--   vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { bg = "none" })
-- end

-- -- 2. Trigger when you manually change themes (or when your theme rotation script runs)
-- autocmd("ColorScheme", {
--   pattern = "*",
--   callback = apply_fito_transparency,
-- })

-- -- 3. Trigger automatically right after LazyVim finishes its entire boot process
-- autocmd("User", {
--   pattern = "VeryLazy",
--   callback = apply_fito_transparency,
-- })

-- -- Ambush Snacks the exact millisecond it lazy-loads into memory
-- autocmd("User", {
--   pattern = "LazyLoad",
--   callback = function(args)
--     -- args.data contains the name of the plugin that just woke up
--     if args.data == "snacks.nvim" then
--       apply_fito_transparency()
--     end
--   end,
-- })
