return {
  'stevearc/oil.nvim',
  lazy = false,
	opts = {
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
		},
	},
  dependencies = { "nvim-tree/nvim-web-devicons", opts = {} },
	keys = {
	  { "-", "<cmd>Oil<cr>", desc = "Open Oil" }
	}
}
