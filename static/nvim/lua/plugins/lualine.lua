return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "folke/snacks.nvim" },
    -- By using a function (_, opts), we take LazyVim's pre-configured lualine table
    -- and mutate only the specific parts we want to change, keeping the rest intact.
    opts = function(_, opts)
      -- 1. Define your custom color palette
      local colors = {
        color1 = "#1f6f88",
        color2 = "#282d3f",
        color3 = "#e86fd8",
        color4 = "#e6e1cf",
        color5 = "#2d3640",
        color8 = "#f07178",
        color9 = "#c1c3ff",
        color10 = "#a4e400",
        color11 = "#d55000",
        color12 = "#00abad",
        color13 = "#4881fa",
      }

      -- 2. Build your custom theme map for every vim mode
      local fito_theme = {
        normal = {
          c = { fg = colors.color9, bg = "NONE" },
          a = { fg = colors.color2, bg = colors.color10, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        insert = {
          a = { fg = colors.color2, bg = colors.color13, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        visual = {
          a = { fg = colors.color2, bg = colors.color3, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        replace = {
          a = { fg = colors.color2, bg = colors.color8, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        inactive = {
          c = { fg = colors.color4, bg = "NONE" },
          a = { fg = colors.color4, bg = colors.color5, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        command = {
          c = { fg = colors.color4, bg = "NONE" },
          a = { fg = colors.color4, bg = colors.color11, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
        terminal = {
          c = { fg = colors.color4, bg = "NONE" },
          a = { fg = colors.color4, bg = colors.color12, gui = "bold" },
          b = { fg = colors.color1, bg = colors.color5 },
        },
      }

      -- 3. Apply the theme
      opts.options.theme = fito_theme

      -- 4. Override sections A and Z with your specific rounded cap separators
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            -- If the mode is NORMAL, change it to NOR
            if str == "NORMAL" then
              return "NOR"
            end
            -- Return the original string for all other modes (INSERT, VISUAL, etc.)
            return str
          end,
          separator = { left = "", right = "" },
          padding = { left = 1, right = 1 },
        },
      }

      opts.sections.lualine_z = {
        {
          "harpoon2",
          icon = "🌺",
          indicators = { "f", "i", "t", "o" },
          active_indicators = { "[f]", "[i]", "[t]", "[o]" },
          -- color_active = { fg = "#ff0048" },
          separator = { right = "", left = "" },
          padding = { left = 0, right = 0 },
        },
      }
      return opts
    end,
  },
}
