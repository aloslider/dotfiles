return {
	"ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	opts = {
		always_trigger = false,
		max_height = 40,
		max_width = 10,
		doc_lines = 40,
		hint_prefix = {
			above = "↙ ",
			current = "← ",
			below = "↖ ",
		},
		toggle_key = '<M-x>',
		select_signature_key = '<M-s>',
	},
	keys = {
		{ mode = { 'n' }, "<leader>k", function() vim.lsp.buf.signature_help() end, desc = "Toggle signature help" },
	},
}

