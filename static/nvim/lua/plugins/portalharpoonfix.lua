return {
  "cbochs/portal.nvim",
  dependencies = {
    "ThePrimeagen/harpoon",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local portal = require("portal")

    -- 1. Expanded Setup
    portal.setup({
      -- Expand this array to increase the maximum visible items.
      -- This example provides 18 slots using the home and top rows.
      labels = {
        "a",
        "s",
        "d",
        "f",
        "g",
        "h",
        "j",
        "k",
        "l",
      },
      window_options = {
        border = "rounded",
      },
    })

    -- 2. The Custom Harpoon 2 Generator
    local function harpoon2_generator(opts, settings)
      local Content = require("portal.content")
      local Iterator = require("portal.iterator")
      local Search = require("portal.search")
      local harpoon = require("harpoon")

      -- Load the expanded labels we just defined above
      settings = settings or require("portal.settings").get()

      opts = vim.tbl_extend("force", {
        direction = "forward",
        max_results = #settings.labels, -- This will now equal 18
      }, opts or {})

      if settings.max_results then
        opts.max_results = math.min(opts.max_results, settings.max_results)
      end

      local marks = harpoon:list().items
      local iter = Iterator:new(marks)

      -- If you call :Portal harpoon backward, it reverses the list
      -- so you see the oldest marks first instead of the newest.
      if opts.direction == Search.direction.backward then
        iter = iter:reverse()
      end

      iter = iter:map(function(v, i)
        if not v or not v.value or v.value == "" then
          return nil
        end

        local buffer = vim.fn.bufexists(v.value) ~= 0 and vim.fn.bufnr(v.value) or vim.fn.bufadd(v.value)

        -- Prevents showing the file you are currently in
        if buffer == vim.fn.bufnr() then
          return nil
        end

        return Content:new({
          type = "harpoon",
          buffer = buffer,
          cursor = {
            row = (v.context and v.context.row) or 1,
            col = (v.context and v.context.col) or 0,
          },
          callback = function(_)
            harpoon:list():select(i)
          end,
          extra = { index = i },
        })
      end)

      iter = iter:filter(function(v)
        return vim.api.nvim_buf_is_valid(v.buffer)
      end)

      -- Truncates the list ONLY if it exceeds your 18 labels
      if not opts.slots then
        iter = iter:take(opts.max_results)
      end

      return { source = iter, slots = opts.slots }
    end

    -- 3. Intercept the builtin module
    package.loaded["portal.builtin.harpoon"] = harpoon2_generator

    -- 4. Keymap
    vim.keymap.set("n", "<C-S-M-i>", "<cmd>Portal harpoon forward<CR>", { desc = "Portal: Harpoon 2 Marks" })
  end,
}
