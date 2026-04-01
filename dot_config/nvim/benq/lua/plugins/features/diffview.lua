return {
	"sindrets/diffview.nvim",
	opts = {},
	keys = {
		{
			"<leader>gf",
			function()
				if vim.fn.exists(":DiffviewClose") == 2 then
					local tabnr = vim.api.nvim_get_current_tabpage()
					local is_diffview_tab = false

					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
						local buf = vim.api.nvim_win_get_buf(win)
						local ft = vim.bo[buf].filetype
						if ft:match("^Diffview") then
							is_diffview_tab = true
							break
						end
					end

					if is_diffview_tab then
						vim.cmd("DiffviewClose")
					else
						vim.cmd("DiffviewFileHistory %")
					end
				else
					vim.notify("Diffview not available", vim.log.levels.WARN)
				end
			end,
			desc = "Toggle diffview file history",
		},
	}
}
