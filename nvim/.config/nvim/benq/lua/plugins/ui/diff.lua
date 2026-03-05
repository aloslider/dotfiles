return {
	'nvim-mini/mini.diff',
	version = false,
	opts = function (_, opts)
		local diff = require('mini.diff')
		opts = {
			source = {
				diff.gen_source.git(),
				diff.gen_source.save()
			},
			view = {
				style = 'sign'
			}
		}
		return opts
	end
}
