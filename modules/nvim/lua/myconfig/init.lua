vim.g.mapleader = " "
vim.g.maplocalleader = "，"

local opt = vim.opt

opt.shiftwidth = 2
opt.tabstop = 2
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.winborder = "single"
opt.list = true
opt.listchars = { space = "·", tab = " →" }
opt.termguicolors = true

local map = vim.keymap.set

map("i", "jj", "<Esc>")
map("i", "<C-k>", "<Up>")
map("i", "<C-j>", "<Down>")
map("i", "<C-h>", "<Left>")
map("i", "<C-l>", "<Right>")
map("i", "<Home>", "<Esc>^i")

map("n", "<C-n>", "<cmd>BufferLineCycleNext<CR>")
map("n", "<C-p>", "<cmd>BufferLineCyclePrev<CR>")
map("n", "<leader>d", "<cmd>bd<CR>")
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>qa<CR>")

map({ "n", "v" }, "<leader>y", '"+y')
map({ "n", "v" }, "<leader>p", '"+p')
