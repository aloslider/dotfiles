return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", 'diff' },
			lualine_y = { "diagnostics" },
			lualine_z = { "location" }
		},
	},
}
