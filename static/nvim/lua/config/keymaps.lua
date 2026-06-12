-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Keymaps are automatically loaded on the VeryLazy event
-- All Hyper commands should go here for translation into Windows Wezterm config

local map = vim.keymap.set

-- Insert mode escapes
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- Movement tweaks
map({ "n", "v" }, "H", "^", { desc = "Go to start of line" })
map({ "n", "v" }, "L", "$", { desc = "Go to end of line" })
map({ "n", "v" }, "{", "}", { desc = "Swap brace movement" })
map({ "n", "v" }, "}", "{", { desc = "Swap brace movement" })

map("n", "<C-d>", "zz<C-d>", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "zz<C-u>", { desc = "Scroll up (centered)" })

map({ "n", "v" }, "<C-h>", "<C-W>h", { desc = "Focus left pane" })
map({ "n", "v" }, "<C-j>", "<C-W>j", { desc = "Focus down pane" })
map({ "n", "v" }, "<C-k>", "<C-W>k", { desc = "Focus up pane" })
map({ "n", "v" }, "<C-l>", "<C-W>l", { desc = "Focus right pane" })

-- Select all
map("n", "<M-y>", "gg<S-v>G")

-- Custom Enter behavior
map("n", "<CR>", "A", { desc = "Append to line" })
map("v", "<CR>", "Di", { desc = "Delete and insert" })

-- Clipboard preservation
map({ "n", "v" }, "c", '"_c', { desc = "Change without yanking" })
map({ "n", "v" }, "C", '"_C', { desc = "Change line without yanking" })
map("v", "p", '"_dP', { desc = "Paste without replacing register" })

-- -- Navigate between quickfix items
-- vim.keymap.set("n", "<leader>h", "<cmd>cnext<CR>zz", { desc = "Forward qfixlist" })
-- vim.keymap.set("n", "<leader>;", "<cmd>cprev<CR>zz", { desc = "Backward qfixlist" })
-- -- Navigate between location list items
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Forward location list" })
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Backward location list" })

-- Search for highlighted text in buffer
map("v", "//", 'y/<C-R>"<CR>', { desc = "Search for highlighted text" })

-- Open Zoxide telescope extension
-- vim.keymap.set("n", "<leader>Z", "<cmd>Zi<CR>", { desc = "Open Zoxide" })

-- Make current file executable
map("n", "<leader>ch", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmodx make current file executable" })

-- Copy file paths
map("n", "<leader>yy", '<cmd>let @+ = expand("%")<CR>', { desc = "Copy File Name" })
map("n", "<leader>yd", '<cmd>let @+ = expand("%:p")<CR>', { desc = "Copy File Path" })

-- -- Marks (Swapped) - I also do this for Yazi, Mini-files and wherever marks are used
-- map("n", "'", "m", { desc = "Set mark" })
-- map("n", "m", "'", { desc = "Jump to mark" })
pcall(vim.keymap.del, { "n", "v", "o" }, "m")
pcall(vim.keymap.del, { "n", "v", "o" }, "'")
map({ "n", "v", "o" }, "'", "m", {
  noremap = true,
  desc = "Set Mark",
})
map({ "n", "v", "o" }, "m", "`", {
  remap = true,
  desc = "Jump to Mark",
})

-- Utility
map("n", "U", "<C-R>", { desc = "Redo" })
map("n", "<M-c>", "gcc", { remap = true, desc = "Comment line" })
map("n", "<M-b>", "gcip", { remap = true, desc = "Comment block" })
map("n", "<M-v>", "<cmd>nohl<CR>", { desc = "Clear search highlights" })
map("n", "<leader>tl", require("treesj").toggle, { desc = "Toggle block on list / line" })
map("n", "<leader>tL", require("treesj").toggle, { desc = "Toggle recursive block on list / line" })

-- Directory
map("n", "<leader>dl", "<cmd>lcd %:p:h<CR>", { desc = "cd to file folder" })
map("n", "<leader>dh", "<cmd>cd ..<CR>", { desc = "cd to parent folder" })
map("n", "<leader>dj", "<cmd>cd ..<CR>", { desc = "cd to previous directory" })

-- Remove defaults
pcall(vim.keymap.del, "n", "<leader>w") -- Removes the base window prefix
pcall(vim.keymap.del, "n", "<leader>wd") -- Removes delete window
pcall(vim.keymap.del, "n", "<leader>w-") -- Removes split window below
pcall(vim.keymap.del, "n", "<leader>w|") -- Removes split window right
pcall(vim.keymap.del, "n", "<leader>wm") -- Removes maximize window
pcall(vim.keymap.del, "n", "<leader>qq") -- Removes quit all menu
pcall(vim.keymap.del, "n", "<leader>|") -- Removes splitwin from leader
pcall(vim.keymap.del, "n", "<leader>-") -- Removes splitwin from leader
pcall(vim.keymap.del, "n", "<leader>.") -- Removes toggle scratch buffer
pcall(vim.keymap.del, "n", "<leader>e") -- Removes Snacks explorer
pcall(vim.keymap.del, "n", "<leader>E") -- Removes Snacks explorer

-- Mini.files as default - to close with the same key we configured on plugin load
map("n", "<leader>e", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, { desc = "mini.files (cwd)" })
map("n", "<leader>E", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "mini.files (root)" })

-- Oil open
-- map({ "n" }, "<leader>o", "<cmd>Oil --float<cr>", { desc = "Oil here" })
map("n", "<leader>o", function()
  require("oil").toggle_float()
end, { desc = "Toggle Oil floating window" })

-- Telescope undo
map({ "n", "v" }, "<S-M-u>", function()
  Snacks.picker.undo()
end, { desc = "Telescope undo" })
map({ "n", "v" }, "<M-u>", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Undotree toggle" })

-- Window/buffer behaviors
map({ "n", "i" }, "<C-q>", "<cmd>confirm q<cr>", { desc = "Confirm Quit" })
map({ "n", "v" }, "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
map({ "n", "v" }, "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all windows" })
-- Cycle buffers with Alt+h/l
map({ "n", "i", "v" }, "<M-h>", "<cmd>bp<CR>", { desc = "Previous buffer" })
map({ "n", "i", "v" }, "<M-l>", "<cmd>bn<CR>", { desc = "Next buffer" })
-- Split panes down and to the right.
map({ "n", "i" }, "<C-w>j", "<cmd>sp<CR>", { desc = "Split window below" })
map({ "n", "i" }, "<C-w>l", "<cmd>vsp<CR>", { desc = "Split window right" })
-- Switches to previous buffer
map("n", "<Tab>", "<cmd>e #<CR>", { desc = "Toggle Alternate File" })

-- Operator Text Objects
local function map_text_obj(lhs, rhs, desc)
  map({ "o", "v" }, lhs, rhs, { remap = true, silent = true, desc = desc })
end
map_text_obj("ae", 'a"', "Around double quotes")
map_text_obj("ie", 'i"', "Inside double quotes")
map_text_obj("am", "a'", "Around single quotes")
map_text_obj("im", "i'", "Inside single quotes")
map_text_obj("an", "a`", "Around backticks")
map_text_obj("in", "i`", "Inside backticks")
map_text_obj("id", "i[", "Inside square brackets")
map_text_obj("ad", "a[", "Around square brackets")
map_text_obj("au", "a{", "Around curly braces")
map_text_obj("iu", "i{", "Inside curly braces")
map_text_obj("aj", "a(", "Around parentheses")
map_text_obj("ij", "i(", "Inside parentheses")

-- -- Multicursor keys
local function mc(action, ...)
  local args = { ... }
  return function()
    require("multicursor-nvim")[action](unpack(args))
  end
end
-- -- Directional Adding
map({ "n", "v" }, "<C-S-k>", mc("lineAddCursor", -1), { desc = "Add cursor above" })
map({ "n", "v" }, "<C-S-j>", mc("lineAddCursor", 1), { desc = "Add cursor below" })
map({ "n", "v" }, "<C-M-k>", mc("lineSkipCursor", -1), { desc = "Jump up without adding cursor" })
map({ "n", "v" }, "<C-M-j>", mc("lineSkipCursor", 1), { desc = "Jump down without adding cursor" })
-- Matching and Skipping
map({ "n", "v" }, "<leader>mn", mc("matchAddCursor", 1), { desc = "Add cursor to next match" })
map({ "n", "v" }, "<leader>ms", mc("matchSkipCursor", 1), { desc = "Skip and add next match" })
map({ "n", "v" }, "<leader>mN", mc("matchAddCursor", -1), { desc = "Add cursor to prev match" })
map({ "n", "v" }, "<leader>mS", mc("matchSkipCursor", -1), { desc = "Skip and add prev match" })
map({ "n", "v" }, "<leader>ma", mc("matchAllAddCursors"), { desc = "Add cursors to all matches" })
-- Mouse and Toggle Utilities
map("n", "<c-leftmouse>", mc("handleMouse"), { desc = "Add/remove cursor with mouse" })
map({ "n", "v" }, "<C-S-q>", mc("toggleCursor"), { desc = "Toggle cursor" })
-- Extra
map({ "n", "x" }, "ga", mc("addCursorOperator"), { desc = "Add cursor to selection" })
map("n", "<leader>ml", mc("alignCursors"), { desc = "Align cursors" })
-- Rotate the text contained in pose visual selection between cursors.
map("x", "<leader>mt", mc("transeachCursors", 1), { desc = "Transpose forward" })
map("x", "<leader>mT", mc("transposeCursors", -1), { desc = "Transpose backward" })
map("x", "I", mc("insertVisual"), { desc = "Insert visual" })
map("x", "A", mc("appendVisual"), { desc = "Append visual" })
-- Increment and Decrement Sequences (Treating all cursors as a sequence)
map({ "n", "x" }, "g<C-a>", mc("sequenceIncrement"), { desc = "Increment sequence across cursors" })
map({ "n", "x" }, "g<C-x>", mc("sequenceDecrement"), { desc = "Decrement sequence across cursors" })
-- Search Result Navigation (Adding cursors based on standard Neovim / searches)
map("n", "<leader>m/n", mc("searchAddCursor", 1), { desc = "Add cursor to next search result" })
map("n", "<leader>m/N", mc("searchAddCursor", -1), { desc = "Add cursor to prev search result" })
map("n", "<leader>m/s", mc("searchSkipCursor", 1), { desc = "Skip and add next search result" })
map("n", "<leader>m/S", mc("searchSkipCursor", -1), { desc = "Skip and add prev search result" })
map("n", "<leader>m/A", mc("searchAllAddCursors"), { desc = "Add cursors to all search results" })
-- The Multicursor Operator
-- Usage Example: `Miwap` -> Creates a cursor on every word inside the paragraph, learn more about text objects
map({ "n", "x" }, "<S-m>", mc("operator"), { desc = "Multicursor Operator" })

-- Harpoon keymaps
local harpoon = require("harpoon")
harpoon:setup()
map("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Add to Harpoon" })
map("n", "<C-S-M-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon explorer" })
-- Select
map("n", "<C-S-M-a>", function()
  harpoon:list():select(1)
end, { desc = "Jump to Harpoon 1" })
map("n", "<C-S-M-s>", function()
  harpoon:list():select(2)
end, { desc = "Jump to Harpoon 2" })
map("n", "<C-S-M-d>", function()
  harpoon:list():select(3)
end, { desc = "Jump to Harpoon 3" })
map("n", "<C-S-M-f>", function()
  harpoon:list():select(4)
end, { desc = "Jump to Harpoon 4" })
-- Move between
-- map("n", "<C-S-M-h>", function()
--   harpoon:list():prev()
-- end, { desc = "Previous Harpoon" })
-- map("n", "<C-S-M-l>", function()
--   harpoon:list():next()
-- end, { desc = "Next Harpoon" })
-- Replace
map("n", "<leader>ha", function()
  harpoon:list():replace_at(1)
end, { desc = "Replace Harpoon 1" })
map("n", "<leader>hs", function()
  harpoon:list():replace_at(2)
end, { desc = "Replace Harpoon 2" })
map("n", "<leader>hd", function()
  harpoon:list():replace_at(3)
end, { desc = "Replace Harpoon 3" })
map("n", "<leader>hf", function()
  harpoon:list():replace_at(4)
end, { desc = "Replace Harpoon 4" })

-- Jumppack extension
map("n", "<C-S-M-o>", function()
  require("Jumppack").start({ offset = -1 })
end, { desc = "Jump back with picker" })
-- map("n", "<C-S-M-i>", function()
--   require("Jumppack").start({ offset = 1 })
-- end, { desc = "Jump forward with picker" })

-- Random colorscheme
local my_themes = {
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
-- The function that handles the randomization
local function set_random_colorscheme()
  -- Seed the randomizer using the current time so it doesn't pick the same sequence
  math.randomseed(os.time())
  -- Pick a random number between 1 and the total number of themes
  local random_index = math.random(#my_themes)
  local selected_theme = my_themes[random_index]
  -- Execute the Neovim command to change the theme
  vim.cmd("colorscheme " .. selected_theme)
  -- Show a nice notification in the UI
  vim.notify("Theme switched to: " .. selected_theme, vim.log.levels.INFO, { title = "Colorscheme" })
end
-- Map this function to <leader>cr (Colorscheme Random)
map("n", "<leader>r", set_random_colorscheme, { desc = "Random Colorscheme" })
