-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Move current line/selection up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Buffers
vim.keymap.set({ 'n', 'v' }, "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set({ 'n', 'v' }, "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set({ 'n', 'v' }, "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set({ 'n', 'v' }, "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Tabs
vim.keymap.set({ 'n', 'v' }, "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set({ 'n', 'v' }, "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set({ 'n', 'v' }, "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set({ 'n', 'v' }, "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
vim.keymap.set({ 'n', 'v' }, "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
vim.keymap.set({ 'n', 'v' }, "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })

-- Windows
vim.keymap.set({ 'n', 'v' }, "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set({ 'n', 'v' }, "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set({ 'n', 'v' }, "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set({ 'n', 'v' }, "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

vim.keymap.set({ 'n', 'v' }, "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set({ 'n', 'v' }, "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set({ 'n', 'v' }, "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set({ 'n', 'v' }, "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("n", "<C-w>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-w>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })

-- Diagnostics
vim.keymap.set('n', "<leader>ld", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Quickfix
vim.keymap.set('n', "<leader>q",
  function()
  	local qf_exists = false
  	for _, win in pairs(vim.fn.getwininfo()) do
  		if win["quickfix"] == 1 then
  			qf_exists = true
  		end
  	end
  	if qf_exists == true then
  		vim.cmd "cclose"
  		return
  	end
  	if not vim.tbl_isempty(vim.fn.getqflist()) then
  		vim.cmd "copen"
  	end
  end,
	{ desc = "Toggle quickfix" })
vim.keymap.set('n', "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })
vim.keymap.set('n', "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
