return {
	"nvim-mini/mini.diff",
	version = false,
	lazy = false,
	config = function()
		local diff = require("mini.diff")
		diff.setup({
			source = {
				diff.gen_source.git(),
				diff.gen_source.save()
			},
			view = {
				style = "sign"
			}
		})
	end,
	keys = {
		{ "<leader>h", function() require("mini.diff").toggle_overlay() end, desc = "Toggle hunks view" },
	},
}
