-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader keys
vim.g.maplocalleader = "|"
vim.g.mapisoleader = "¤"

-- Tidal Globals
vim.g.tidal_no_mappings = 1

-- Editor Options
vim.opt.swapfile = false
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.scrolloff = 4
-- So that title is updated even with v()
vim.opt.title = true

-- Cursorhold event reduce time
vim.opt.updatetime = 100
-- Markdown conceal
vim.opt.conceallevel = 2

-- vim.filetype.add({
--   extension = {
--     kbd = "kanata",
--   },
-- })

-- Langmap swaps, didn't work
-- vim.opt.langmap = "m';'m"
