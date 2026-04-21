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
