require("config.autocmds")
require("config.options")
require("config.keymaps")

require("config.lazy")
require("config.theme") -- ignored by git

vim.lsp.config("roslyn", require("config.lsp.roslyn"))

vim.lsp.enable({ "nixd" }) -- installed locally

-- Set custom breakpoint style
vim.fn.sign_define('DapBreakpoint', {
	text = '⚪',
	texthl = 'DapBreakpointSymbol',
	linehl = 'DapBreakpoint',
	numhl = 'DapBreakpoint'
})
vim.fn.sign_define('DapStopped', {
	text = '🔴',
	texthl = 'yellow',
	linehl = 'DapBreakpoint',
	numhl = 'DapBreakpoint'
})
vim.fn.sign_define('DapBreakpointRejected', {
	text = '⭕',
	texthl = 'DapStoppedSymbol',
	linehl = 'DapBreakpoint',
	numhl = 'DapBreakpoint'
})

