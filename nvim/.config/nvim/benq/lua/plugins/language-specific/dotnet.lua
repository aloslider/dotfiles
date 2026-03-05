return {
	{ "nvim-neotest/nvim-nio" },
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
		},
		config = function()
			require "configs.nvim-dap"
		end,
		event = "VeryLazy",
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require "configs.nvim-dap-ui"
		end,
	},
	{
		"nvim-neotest/neotest",
		requires = {
			"Issafalcon/neotest-dotnet",
		},
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter"
		},
		config = function ()
			require("neotest").setup({
				adapters = {
					require("neotest-dotnet")
				}
			})
		end
	},
	{
		"Issafalcon/neotest-dotnet",
		lazy = false,
		dependencies = {
			"nvim-neotest/neotest"
		}
	},
	{
		"MonsieurTib/neonuget",
		opts = {},
		dependencies = {
			"nvim-lua/plenary.nvim",
		}
	}
}
