return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig", },
		opts = {
			ensure_installed = {
				"docker_compose_language_service",
				"lua_ls",
				"html",
				-- "roslyn", install with :MasonInstall
				"vtsls",
				"vue_ls",
			},
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "neovim/nvim-lspconfig", },
		opts = {
			ensure_installed = {
				"coreclr",
			}
		}
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "mason-org/mason.nvim", }
	},
	{
		"mason-org/mason.nvim",
		opts = {
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
		}
	}
}
