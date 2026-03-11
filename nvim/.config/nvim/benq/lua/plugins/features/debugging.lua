return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
      "rcarriga/nvim-dap-ui",
    },
		keys = {
			{ "<F5>",  function() require("dap").continue() end, desc = "[DBG] Continue" },
			{ "<F7>",  function() require("dap").terminate() end, desc = "[DBG] Terminate" },
			{ "<F8>",  function() require("dap").step_out() end, desc = "[DBG] Step out" },
			{ "<F9>",  function() require("dap").toggle_breakpoint() end, desc = "[DBG] Toggle breakpoint" },
			{ "<F10>", function() require("dap").step_over() end, desc = "[DBG] Step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "[DBG] Step into" },
		}
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap"
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- open ui immediately when debugging starts
			dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
			dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

			dapui.setup({
				expand_lines = true,
				controls = { enabled = false },
				floating = { border = "rounded" },
				render = {
					max_type_length = 60,
					max_value_lines = 200,
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 1.0 },
						},
						size = 15,
						position = "bottom",
					},
				},
			})
		end,
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI", noremap = true, silent = true },
			{ "<leader>dw", function() require("dapui").eval(nil, { enter = true }) end, desc = "Add word to Watches" },
		}
	}
}
