return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, {
        mode = { "n", "v" },
        -- You just label the 'folders' here
        { "<leader>m", group = "Multicursor" },
        { "<leader>i", group = "Insert" },
        { "<leader>w", desc = "Save File" },
        { "<leader>h", desc = "Harpoon Replacer" },
        { "<leader>S", desc = "Session" },
        { "<leader>d", desc = "Directory/debug" },
        { "<leader>q", desc = "Delete buffer" },
        { "<leader>t", desc = "Transformations" },
      })
    end,
  },
}
