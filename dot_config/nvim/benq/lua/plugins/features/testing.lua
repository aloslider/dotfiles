return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vstest")
				}
			})
		end,
		keys = {
			{ "<F6>",  function() require("neotest").run.run({strategy = "dap"}) end, desc = "Run tests" },
		}
	}
}
