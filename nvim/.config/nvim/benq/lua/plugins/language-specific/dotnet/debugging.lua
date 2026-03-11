return {
	"ramboe/ramboe-dotnet-utils",
	dependencies = { "mfussenegger/nvim-dap" },
	config = function()
		local dap = require("dap")
		local utils = require("dap-dll-autopicker")
		local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"
		local netcoredbg_adapter = {
			type = "executable",
			command = mason_path,
			args = { "--interpreter=vscode" },
		}
		dap.adapters.netcoredbg = netcoredbg_adapter
		dap.adapters.coreclr = netcoredbg_adapter
		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "launch - netcoredbg",
				request = "launch",
				program = function()
					return utils.build_dll_path()
				end,
			},
		}
	end,
}
