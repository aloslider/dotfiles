local picker = "fzf-lua"

return {
  "uhs-robert/sshfs.nvim",
  opts = {
		ui = {
			file_picker = {
				preferred_picker = picker,
			},
			remote_picker = {
				preferred_picker = picker,
			}
		},
	},
}
