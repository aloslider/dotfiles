return {
	{
		'stevearc/conform.nvim',
		opts = {
			async = true,
			formatters_by_ft = {
				cs = { "csharpier" },
				css = { "prettier" },
				html = { "prettier" },
				csproj = { "xmlformat" },
				xml = { "xmlformat" },
				caddy = { 'caddy' },
			},
			formatters = {
				xmlformat = {
					command = "xmlformat",
					-- args = { "--overwrite" },
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
	}
}
