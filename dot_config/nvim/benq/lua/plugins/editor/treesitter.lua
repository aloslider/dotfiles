return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"c",
				"caddy",
				"c_sharp",
				"css",
				"csv",
				"html",
				"javascript",
				"json",
				"nix",
				"sql",
				"typescript",
				"vimdoc",
				"zsh",
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			vim.g.no_plugin_maps = true
		end,
		opts = {}
	}
}
