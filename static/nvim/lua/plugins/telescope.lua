return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "debugloop/telescope-undo.nvim",
    },
    -- 1. Use a function to safely inject your mappings and extensions
    opts = function(_, opts)
      local actions = require("telescope.actions")

      -- Ensure the sub-tables exist before we write to them
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = opts.defaults.mappings or {}
      opts.extensions = opts.extensions or {}

      -- 2. Migrate your Insert Mode mappings
      opts.defaults.mappings.i = vim.tbl_extend("force", opts.defaults.mappings.i or {}, {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
      })

      -- 3. Migrate your Normal Mode mappings
      opts.defaults.mappings.n = vim.tbl_extend("force", opts.defaults.mappings.n or {}, {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      })

      -- 4. Reconstruct your Telescope Undo aesthetic and layout
      opts.extensions.undo = {
        use_delta = true,
        side_by_side = true,
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.8,
          height = 0.9,
          preview_width = 0.7,
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        initial_mode = "normal",
        entry_format = "$ID $STAT $TIME",
      }
    end,

    -- -- 5. Force Telescope to initialize the Undo extension after setup
    -- config = function(_, opts)
    --   local telescope = require("telescope")
    --   telescope.setup(opts)
    --   telescope.load_extension("undo")
    -- end,
  },
}
