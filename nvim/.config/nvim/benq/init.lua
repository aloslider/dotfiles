require("config.autocmds")
require("config.options")
require("config.keymaps")

require("config.lazy")

vim.lsp.enable({ "nixd" }) -- installed locally

vim.diagnostic.config({
	virtual_lines = {
		current_line = true
	},
	update_in_insert = true
})
