return {
	'saghen/blink.cmp',
	version = '1.*',
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = 'default' },
		appearance = {
			nerd_font_variant = 'mono'
		},
		completion = { documentation = { auto_show = true } },
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer' },
			per_filetype = {
				sql = { 'dadbod' },
				lua = {
					inherit_defaults = true,
					-- 'lazydev'
				}
			},
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" }
}
