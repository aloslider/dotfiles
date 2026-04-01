return {
	"stevearc/conform.nvim",
	opts = {
		async = true,
		formatters_by_ft = {
			cs = { "csharpier" },
			csproj = { "xmlformat" },
			css = { "prettier" },
			html = { "prettier" },
			nix = { "nixfmt" },
			xml = { "xmlformat" },
		},
		formatters = {
			xmlformat = {
				command = "xmlformat",
			},
			csharpier = {
				command = "csharpier",
				args = {
					"format",
					"--write-stdout",
				},
				to_stdin = true,
			},
		},
	},
	keys = {
		{
			mode = { "n", "v" },
			"<leader>cF",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Format buffer",
		},
		{
			mode = "n",
			"<leader>cf",
			function()
				local start_line = vim.fn.line(".")
				local end_line = start_line

				require("conform").format({
					async = true,
					lsp_fallback = true,
					range = {
						start = { start_line, 0 },
						["end"] = { end_line, 999999 },
					},
				})
			end,
			desc = "Format line",
		},
	}
}
