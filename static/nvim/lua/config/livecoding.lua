local map = vim.keymap.set

-- Tidal Cycles
map({ "n", "i", "v" }, "<M-h>", "<cmd>TidalHush<CR>", { desc = "Tidal Hush" })
map({ "n", "i", "v" }, "<M-n>", "<cmd>TidalSend<CR>", { desc = "Tidal Send" })
map({ "n", "v" }, "<M-m>", "<cmd>'{+1,'}-1TidalSend<CR>", { desc = "Tidal Send Paragraph" })
map("i", "<M-m>", "<Esc>:'{+1,'}-1TidalSend<CR>", { desc = "Tidal Send Paragraph" })

for i = 1, 9 do
  map("n", "<localleader>" .. i, "<cmd>TidalSilence " .. i .. "<CR>", { desc = "Silence " .. i })
  map("n", "<localleader><localleader>" .. i, "<cmd>TidalPlay " .. i .. "<CR>", { desc = "Play " .. i })
end

-- Undotree
map("n", "<leader>t", "<cmd>Telescope undo<CR>", { desc = "Telescope Undo" })
