-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end
-- Future
-- https://github.com/kevinhwang91/nvim-bqf

return {
  -- Add languages to conform, remember to install them on mason
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt", "injected" }, -- or "nixpkgs-fmt" or "alejandra"
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        toml = { "taplo" },
        kdl = { "kdlfmt" },
      },
    },
  },
-- Treesitter config
 {
  "nvim-treesitter/nvim-treesitter",

    --  this is for the weird patched highlights version
-- init = function()
--       require("nvim-treesitter.parsers").kanata = {
--         install_info = {
--           url = "https://github.com/postsolar/tree-sitter-kanata",
--           files = { "src/parser.c" },
-- branch = "master",
--         },
--         filetype = "kbd",
--       }
--       vim.api.nvim_create_autocmd("User", {
--         pattern = "TSUpdate",
--         callback = function()
--           require("nvim-treesitter.parsers").kanata = {
--             install_info = {
--               url = "https://github.com/postsolar/tree-sitter-kanata",
--               files = { "src/parser.c" },
-- branch = "master",
--             },
--             filetype = "kbd",
--           }
--         end,
--       })
--     end,

  opts = function(_, opts)

      --- this is added in the scheme version
    vim.filetype.add({ extension = { kbd = "kbd" } })
    vim.treesitter.language.register("scheme", "kbd")

    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, { 
        "nix", 
        "kdl",
        "bash", 
        "lua", 
        "json", 
        "toml",
        "ini",
          -- "kanata",
            "scheme",
        "markdown",
        "markdown_inline", -- Required for formatting code blocks inside Markdown
        "hyprlang",
        "yaml",
        "zsh"
      })
    end
    end,
},


  -- Custom Tools
  { "ZSaberLv0/ZFVimDirDiff", dependencies = { "ZSaberLv0/ZFVimJob" } },
  { "andrewferrier/wrapping.nvim", config = true },
  { "carlosrocha/chrome-remote.nvim" },
  { "tpope/vim-surround" },
  { "eandrju/cellular-automaton.nvim" },
  { "tidalcycles/vim-tidal" },
{"mluders/comfy-line-numbers.nvim"},

-- bad behavior
-- {
--     "karb94/neoscroll.nvim",
--     opts = {
--       -- Leave this empty or add global preferences like easing
--       easing_function = "sine",
--       hide_cursor = true,
--     },
--   config = function(_, opts)
--   local neoscroll = require("neoscroll")
--   neoscroll.setup(opts)
--
--   vim.o.scrolloff = 999
--
--   vim.keymap.set("n", "<C-d>", function()
--     neoscroll.scroll(math.floor(vim.api.nvim_win_get_height(0) / 2), {move_cursor=true, duration=120})
--   end, { noremap = true, silent = true })
--
--   vim.keymap.set("n", "<C-u>", function()
--     neoscroll.scroll(-math.floor(vim.api.nvim_win_get_height(0) / 2), {move_cursor=true, duration=120})
--    end, { noremap = true, silent = true })
-- end,
-- },
{
  "knownasnaffy/himalaya.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- Optional configuration
    -- icons_enabled = false, -- set to true to use nerd font icons
    -- wrap_folder_navigation = true,
  },
},

{
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- 1. Remove the closing 'x' icons
        show_buffer_close_icons = false,
        show_close_icon = false,

        -- 2. Tab sizing rules
        enforce_regular_tabs = false,
        max_name_length = 20,
        tab_size = 10,
      },
    },
  },

{
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
  config = function()
    require("treesj").setup({
        max_join_length=200,
      })
  end,
},

-- {
--   "nvim-treesitter/nvim-treesitter-textobjects",
--   branch = "main",
--   init = function()
--     -- Disable entire built-in ftplugin mappings to avoid conflicts.
--     -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
--     vim.g.no_plugin_maps = true
--     -- Or, disable per filetype (add as you like)
--     -- vim.g.no_python_maps = true
--     -- vim.g.no_ruby_maps = true
--     -- vim.g.no_rust_maps = true
--     -- vim.g.no_go_maps = true
--   end,
--   config = function()
--     -- put your config here
--   end,
-- },

  {
    "abecodes/tabout.nvim",
    lazy = false,
    config = function()
      require("tabout").setup {
        tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = "<C-d>", -- reverse shift default action,
        enable_backwards = true, -- well ...
        completion = false, -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' }
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {} -- tabout will ignore these filetypes
      }
    end,
    dependencies = { -- These are optional
      "nvim-treesitter/nvim-treesitter",
      "L3MON4D3/LuaSnip",
      "hrsh7th/nvim-cmp"
    },
    opt = true,  -- Set this to true if the plugin is optional
    event = "InsertCharPre", -- Set the event to 'InsertCharPre' for better compatibility
    priority = 1000,
  },
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      -- Disable default tab keybinding in LuaSnip
      return {}
    end,
  },

{
  "code-biscuits/nvim-biscuits",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
  default_config = {
    max_length = 50,
  -- trim_by_words=true,
    min_distance = 5,
    prefix_string = "  ❯❯ ",
    -- cursor_line_only=true,
  },
  }
},



  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = {
      'KittyScrollbackGenerateKittens',
      'KittyScrollbackCheckHealth',
      'KittyScrollbackGenerateCommandLineEditing',
    },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      require('kitty-scrollback').setup()
    end,
  },

  {
    "jake-stewart/multicursor.nvim",
    -- branch = "1.0",
    event="VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      -- The keymap layer is active ONLY when multiple cursors exist on the screen
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one
        layerSet({"n", "v"}, "<left>", mc.prevCursor)
        layerSet({"n", "v"}, "<right>", mc.nextCursor)
        -- 3. Delete the main cursor (Changed from <leader>x to prevent Diagnostics clash)
        layerSet({"n", "v"}, "<leader>mx", mc.deleteCursor)
        -- 4. Enable and clear cursors using escape, while preserving native highlight clearing
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
            -- Explicitly call the native highlight clear so we don't lose the base functionality
            vim.cmd("nohlsearch")
          end
        end)
      end)
      -- Initialize custom highlight groups
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn"})
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
    end,
  },
  -- {'jake-stewart/multicursor.nvim',
  --
  --   config = function()
  --       local mc = require("multicursor-nvim")
  --       mc.setup()
  --
  --       local set = vim.keymap.set
  --
  --       -- Add or skip cursor above/below the main cursor.
  --       set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
  --       set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
  --   end,
  -- },

  {
    "nvim-mini/mini.files",
    opts = {
    options={
      permanent_delete = false,
    },
    mappings = {
      mark_goto   = "m",
      mark_set    = "'",
},
},
      config = function(_, opts)
      -- Initialize the plugin
      require("mini.files").setup(opts)
      -- Create the autocommand to bind keys every time mini.files opens
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Buffer-local mapping: Closes mini.files when you are inside it
          vim.keymap.set("n", "<leader>e", function()
            require("mini.files").close()
          end, {
            buffer = buf_id,
            desc = "Close mini.files (Toggle)",
          })
          vim.keymap.set("n", "<Esc>", function()
          require("mini.files").close()
        end, {
          buffer = buf_id,
          desc = "Close mini.files with Esc",
        })
        end,
      })
    end,
  },

{
  "chrishrb/gx.nvim",
  keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open link/file (gx.nvim)" } },
  cmd = { "Browse" },
  init = function ()
    vim.g.netrw_nogx = 1 -- disable netrw gx
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = true,
},

-- {
--    "m4xshen/hardtime.nvim",
--    lazy = false,
--    dependencies = { "MunifTanjim/nui.nvim" },
--    opts = {
--       disabled_keys = {
--         ["<Up>"] = false, -- Allow <Up> key
--         ["<Down>"] = false, -- Allow <Up> key
--       },
--     },
-- },


{
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function()
    require("oil").setup({
      default_file_explorer = true,
    columns = {
      "icon",
      -- "permissions",
      -- "size",
      -- "mtime",
    },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      win_options = {
        wrap = true,
      },
float = {
      padding = 2,
      max_width = 0.9,       -- or 0.4 for 40% of screen width
      max_height = 0.5,     -- or 0.8 for 80% of screen height
      border = "rounded",   -- optional: "none", "single", "double", etc.
      win_options = {
        winblend = 0,       -- transparency (0-100)
      },
    },

  -- keymaps = {
  --   ["g?"] = { "actions.show_help", mode = "n" },
  --   ["<CR>"] = "actions.select",
  --   ["<C-s>"] = { "actions.select", opts = { vertical = true } },
  --   ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
  --   ["<C-t>"] = { "actions.select", opts = { tab = true } },
  --   ["<C-p>"] = "actions.preview",
  --   ["<C-c>"] = { "actions.close", mode = "n" },
  --   ["<C-l>"] = "actions.refresh",
  --   ["-"] = { "actions.parent", mode = "n" },
  --   ["_"] = { "actions.open_cwd", mode = "n" },
  --   ["`"] = { "actions.cd", mode = "n" },
  --   ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
  --   ["gs"] = { "actions.change_sort", mode = "n" },
  --   ["gx"] = "actions.open_external",
  --   ["g."] = { "actions.toggle_hidden", mode = "n" },
  --   ["g\\"] = { "actions.toggle_trash", mode = "n" },
  -- },
    })
  end,
},

{
    "folke/persistence.nvim",
    keys = {
      -- Disable the default LazyVim session keymaps
      { "<leader>qs", false },
      { "<leader>qS", false },
      { "<leader>qd", false },
      { "<leader>ql", false },

      -- Define your new keymaps under <leader>S
      { "<leader>Ss", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>SS", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>Sd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },


{
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
},

-- {
--     "cbochs/portal.nvim",
--     dependencies = {
--         "ThePrimeagen/harpoon",
--     },
-- },

  {
    "letieu/harpoon-lualine",
    dependencies = {
      {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
      }
    },
  },

{
  'suliatis/Jumppack.nvim',
  options={
      global_mappings=false,
  },
    mappings={
    jump_back = 'j',
    jump_forward = 'k',
    },
},
  -- -- Marks with your custom config
  -- {
  --   "chentoast/marks.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     default_mappings = false,
  --     signs = true,
  --     force_write_shada = false,
  --     refresh_interval = 250,
  --     sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  --     excluded_filetypes = { "qf", "neo-tree", "toggleterm", "TelescopePrompt" },
  --   },
  -- keys = {
  --   preview = "",
  -- }
  -- },







  -- Undotree updated
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    -- keys = {
    --   { "<M-u>", "<cmd>lua require('undotree').toggle()<cr>", desc = "Toggle Undotree" }
    -- },
    opts = {
      float_diff = false,
      layout = "left_left_bottom",
      position = "left",
      parser = "compact",
      window = { width = 0.25, height = 0.25, border = "rounded" },
      keymaps = {
          ["j"] = "move_next",
          ["k"] = "move_prev",
          ["gj"] = "move2parent",
          ["J"] = "move_change_next",
          ["K"] = "move_change_prev",
          ["<cr>"] = "action_enter",
          ["p"] = "enter_diffbuf", -- this can switch between preview and undotree window
          ["q"] = "quit",
          ["S"] = "update_undotree_view",
      },
    }
  },

  -- Color picker
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>iv", function() require("oklch-color-picker").pick_under_cursor() end, desc = "Color pick under cursor" },
    },
    opts = { highlight = { style = "foreground+virtual_eol", italic = true, bold = true, virtual_text = '' } }
  },

  -- Telescope extensions mapping adjustments
  {
    "nvim-telescope/telescope.nvim",
    -- Telescope undotree does a better job with Ctrl yY and Enter to restore
    -- dependencies = { "debugloop/telescope-undo.nvim" },
    keys = {
       -- { "<leader>t", function() require("telescope").extensions.undo.undo() end, desc = "Telescope Undo" },
    },
    pickers = {
      find_files = {
        find_command = {
          "sh",
          "-c",
          "(fasd -Rfl 2>/dev/null; fd --type f --hidden) | awk 'seen[$ 0]++ == 0'"
        }
      }
    }
  },

--=============
--==|| MASON DISABLE AND DIRENV DEPENDENCIES
--=============
{
    "direnv/direnv.vim",
    lazy = false,
  },

{
    "neovim/nvim-lspconfig",
    opts = {
      -- Ensure Mason is NOT used for any server
      setup = {
        ["*"] = function(server, opts) end,
      },
      servers = {
        -- List the servers you have in your Nix flake/shared.nix
        -- nil_ls = {},
        lua_ls = {},
        bashls = {},
        marksman = {},
        yamlls = {},
            nixd = {
            settings = {
    nixd = {
      diagnostic = {
        suppress = { "sema-duplicated-attrname" },
      },
    },
  },
      },
    },
  },
  },

-- 1. Disable Mason core
  { "mason-org/mason.nvim", enabled = false },
  
  -- 2. Disable the Mason-LSP bridge
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  
  -- 3. Disable Mason-dependent tool installers
  { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },

}
