return {
	"lewis6991/gitsigns.nvim",
	opts = {
		-- signs_staged_enable = false,
		-- signcolumn = false,
	},
	keys = {
		{ "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
		{ "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
		{ "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
		{ "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
		{ "<leader>gb", function() require("gitsigns").blame_line() end, desc = "Blame line" },
	}
}
