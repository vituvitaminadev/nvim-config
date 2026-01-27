return {
	'saghen/blink.cmp',
	version = '1.*',

	opts = {
		keymap = {
			preset = 'default',
			["<C><leader>"] = { "show" }
		},

		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = 'mono'
		},

		completion = {
			documentation = { auto_show = true },
		},
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer'},
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },

		signature = { enabled = true }
	},
	opts_extend = { 'sources.default' }
}
