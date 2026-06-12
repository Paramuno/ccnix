local uv = vim.uv or vim.loop
-- Using a simple text file instead of JSON is faster to parse via native Lua
local track_file = vim.fn.stdpath("state") .. "/active_themes.txt"
local current_pid = uv.os_getpid()

-- 1. Define the expanded pool of themes
local all_themes = {
  "one_monokai",
  "everforest",
  "tokyonight",
  "dracula",
  "kanagawa",
  "gruvbox",
  "onedark",
  "sonokai",
  "fluoromachine",
}

local used_themes = {}
local active_instances = {}

-- 2. Blazing fast read using raw Lua I/O (bypassing Vimscript)
local f = io.open(track_file, "r")
if f then
  for line in f:lines() do
    -- Fast pattern matching for "pid=theme"
    local pid_str, theme = line:match("^(%d+)=(.*)$")
    if pid_str and theme then
      local pid = tonumber(pid_str)
      if pid and pid ~= current_pid then
        -- Ping the OS to see if the PID is still alive
        if uv.kill(pid, 0) == 0 then
          table.insert(active_instances, pid .. "=" .. theme)
          used_themes[theme] = true
        end
      end
    end
  end
  f:close()
end

-- 3. Determine which themes are free to use
local available_themes = {}
for _, theme in ipairs(all_themes) do
  if not used_themes[theme] then
    table.insert(available_themes, theme)
  end
end

-- Fallback: Reset the pool if all 9 themes are currently taken
if #available_themes == 0 then
  available_themes = all_themes
end

-- 4. Pick a random theme
math.randomseed(os.time() + current_pid)
local active_theme = available_themes[math.random(#available_themes)]

-- 5. Save the state back using raw Lua I/O
table.insert(active_instances, current_pid .. "=" .. active_theme)
f = io.open(track_file, "w")
if f then
  f:write(table.concat(active_instances, "\n") .. "\n")
  f:close()
end

-- 6. Return the plugin configurations dynamically
return {
  {
    "cpea2506/one_monokai.nvim",
    lazy = active_theme ~= "one_monokai",
    priority = active_theme == "one_monokai" and 1000 or nil,
    opts = {
      transparent = true,
      colors = {},
      highlights = function(colors)
        return {
          LineNr = { fg = "#753b5e" },
          CursorLineNr = { fg = "#e5c07b", bold = true },
          StatusLine = { bg = "NONE", fg = colors.white },
          StatusLineNC = { bg = "NONE", fg = colors.grey },
        }
      end,
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = active_theme ~= "tokyonight",
    priority = active_theme == "tokyonight" and 1000 or nil,
    opts = {
      colors = {},
      overrides = function()
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          LineNr = { fg = "#753b5e" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
        }
      end,
    },
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = active_theme ~= "dracula",
    priority = active_theme == "dracula" and 1000 or nil,
    opts = {
      colors = {},
      overrides = function()
        return {
          LineNr = { fg = "#753b5e" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
        }
      end,
    },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = active_theme ~= "kanagawa",
    priority = active_theme == "kanagawa" and 1000 or nil,
    opts = {
      overrides = function()
        return {
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          LineNr = { fg = "#753b5e", bg = "none" },
          SignColumn = { bg = "none" },
          FoldColumn = { bg = "none" },

          DiagnosticSignError = { bg = "none" },
          DiagnosticSignWarn = { bg = "none" },
          DiagnosticSignInfo = { bg = "none" },
          DiagnosticSignHint = { bg = "none" },
          DiagnosticSignOk = { bg = "none" },
          LightBulbSign = { bg = "none" },

          GitSignsAdd = { bg = "none" },
          GitSignsChange = { bg = "none" },
          GitSignsDelete = { bg = "none" },
        }
      end,
    },
  },
  {
    "neanias/everforest-nvim",
    lazy = active_theme ~= "everforest",
    priority = active_theme == "everforest" and 1000 or nil,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = active_theme ~= "gruvbox",
    priority = active_theme == "gruvbox" and 1000 or nil,
    opts = {
      colors = {},
      highlights = function(colors)
        return {
          LineNr = { fg = "#753b5e" },
          StatusLine = { bg = "NONE", fg = colors.white },
          StatusLineNC = { bg = "NONE", fg = colors.grey },
        }
      end,
    },
  },
  {
    "navarasu/onedark.nvim",
    lazy = active_theme ~= "onedark",
    priority = active_theme == "onedark" and 1000 or nil,
    opts = {
      style = "warmer",
    },
  },
  {
    "sainnhe/sonokai",
    lazy = active_theme ~= "sonokai",
    priority = active_theme == "sonokai" and 1000 or nil,
    opts = {
      colors = {},
      overrides = function()
        return {
          LineNr = { fg = "#753b5e" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
        }
      end,
    },
  },
  {
    "maxmx03/fluoromachine.nvim",
    lazy = active_theme ~= "fluoromachine",
    priority = active_theme == "fluoromachine" and 1000 or nil,
    opts = {
      theme = "retrowave",
      overrides = function(c)
        return {
          -- Flatten the standard floating window background
          NormalFloat = { bg = c.bg },
          FloatBorder = { bg = c.bg },
          -- FloatBorder = { bg = c.bg, fg = c.bg },

          -- Target specific Snacks.nvim components to match the main background
          SnacksNormal = { bg = c.bg },
          SnacksNormalNC = { bg = c.bg },
          SnacksFloat = { bg = c.bg },
          SnacksExplorerNormal = { bg = c.bg },
          SnacksPickerNormal = { bg = c.bg },
          SnacksDashboardNormal = { bg = c.bg },
          SnacksFloatBorder = { bg = c.bg, fg = c.comment },

          -- Telescope splits its UI into three main boxes: Prompt, Results, and Preview
          TelescopeNormal = { bg = c.bg },
          TelescopePromptNormal = { bg = c.bg },
          TelescopeResultsNormal = { bg = c.bg },
          TelescopePreviewNormal = { bg = c.bg },
          -- Matching the borders to keep the styling sharp
          TelescopeBorder = { bg = c.bg, fg = c.comment },
          TelescopePromptBorder = { bg = c.bg, fg = c.comment },
          TelescopeResultsBorder = { bg = c.bg, fg = c.comment },
          TelescopePreviewBorder = { bg = c.bg, fg = c.comment },
          -- Optional: You can also change the title backgrounds if they look out of place
          TelescopePromptTitle = { bg = c.purple, fg = c.bg },
          TelescopePreviewTitle = { bg = c.green, fg = c.bg },
          TelescopeResultsTitle = { bg = c.cyan, fg = c.bg },
        }
      end,
    },
  },
  -- Note: 'retrobox' is purposely omitted from the plugin list.
  -- Since Neovim 0.10, it is a built-in colorscheme, meaning Lazy
  -- doesn't need to download or manage a repository for it.

  -- 7. Tell LazyVim which theme won the calculation
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = active_theme,
      -- colorscheme = "one_monokai",
    },
  },
}
