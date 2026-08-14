vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		source = "if_many",
		prefix = "●",
	},
	signs = true,
	update_in_insert = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
	jump = {
		wrap = true,
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
			})
		end,
	},
})

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
