local picker = "fzf-lua"

return {
  "uhs-robert/sshfs.nvim",
  opts = {
		ui = {
			local_picker = {
				preferred_picker = picker,
			},
			remote_picker = {
				preferred_picker = picker,
			}
		},
	},
}
