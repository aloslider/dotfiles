return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		filesystem = {
      follow_current_file = {
        enabled = true,
      },
    },
	},
	keys = {
		{
			"<leader>e",
			function ()
				require("neo-tree.command").execute({ toggle = true })
			end,
		  desc = "Open neo-tree"
		}
	}
}
