return {
	{
		"GustavEikaas/easy-dotnet.nvim",
    enabled = false,
		dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "ibhagwan/fzf-lua", },
		opts = {},
	},
	{
		"MonsieurTib/neonuget",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
		keys = {
			{ "<leader>nn", "<cmd>NuGet<cr>", desc = "Open NuGet" }
		}
	}
}
