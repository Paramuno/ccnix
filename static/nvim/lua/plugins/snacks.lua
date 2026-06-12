return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>S", false },
      {
        "<leader>bs",
        function()
          Snacks.scratch()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader><leader>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart Find Files (Frecency)",
      },
      {
        "<leader>bS",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>q",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
    },
    opts = {
      styles = {
        float = { backdrop = false },
        -- Disables the background darkening for Lazygit
        lazygit = { backdrop = false },

        -- Disables the background darkening for floating terminals
        terminal = { backdrop = false },

        -- Disables the background darkening for the Snacks Picker
        picker = { backdrop = false },

        -- Disables it for Zen mode (if you use it)
        zen = { backdrop = true },

        -- Disables it for the scratchpad
        scratch = { backdrop = false },
      },

      picker = {
        sources = {
          -- Configure the file finder
          files = {
            hidden = true, -- Show hidden files and folders (e.g., .config, .env)
            ignored = false, -- Keep this false so it still respects .gitignore (optional)
          },
          -- Configure the text searcher (live grep)
          grep = {
            hidden = true, -- Search inside hidden files and folders
            ignored = false,
          },
          -- snacks explorer
          explorer = {
            hidden = true,
            layout = {
              layout = {
                width = 25, -- Sets a fixed width of 25 columns. Adjust to your liking.
                -- width = 0.15, -- Takes up 15% of the screen width
              },
            },
          },
        },
        win = {
          input = {
            winhighlight = "NormalFloat:Normal,FloatBorder:Normal,SnacksPickerNormal:Normal,SnacksPickerBorder:Normal",
          },
          list = {
            winhighlight = "NormalFloat:Normal,FloatBorder:Normal,SnacksPickerNormal:Normal,SnacksPickerBorder:Normal",
          },
          preview = {
            winhighlight = "NormalFloat:Normal,FloatBorder:Normal,SnacksPickerNormal:Normal,SnacksPickerBorder:Normal",
          },
        },
      },

      dashboard = {
        -- 1. Your advanced dual-pane layout
        sections = {
          { section = "header", padding = 0 },
          {
            pane = 2,
            section = "terminal",
            cmd = "/usr/bin/colorscript -e square",
            height = 5,
            padding = 1,
          },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },

        -- 2. Injecting your custom ASCII art as the main header
        preset = {
          header = [[
   ,dPYb,        I8                                                  
   IP'`Yb        I8                                                  
   I8  8I  ✿✿  8888888                       ✿✿                      
   I8  8'  ::    I8                         :::                      
   I8 dP   gg    I8    ,ggggg,  ,ggg    gg  gg    ,ggg,,ggg,,gg,     
   I8dP    88    I8   d8⠛   ⠛8gg8⠛Yb   88bg88   ,8⠛ ⠛8P⠛ ⠛8P⠛ ⠛8,    
  ,d8b,_ _d88,_,,88,,,P8,   ,88'  I8, ,8I  88,_,dP   88   88   Yb,   
  PI8⠛8888P⠛⠛Y88P⠛⠛Y8P⠛Y8888P⠛     ⠛Y8P⠛   ⠛Y888P'   8I   8I   '88   
   I8 `8,                                                            
   I8  `8,                                                           
   I8   8I                                                           
   I8   8I                                                           
   I8, ,8'                                                           
    ⠛Y8P⠛                                                            ]],
        },
      },
    },
  },
}
