return {
	{
		'nvim-telescope/telescope.nvim',
		branch = 'master',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
			'andrew-george/telescope-themes'
		},
		config = function()
			local telescope = require('telescope')
			telescope.setup {
				defaults = {
					preview = {
						treesitter = {
							disable = { "markdown" },
						},
					},
				},
				pickers = {
					-- find_files = {
					-- 	theme = "ivy",
					-- }
				},
				extensions = {
					fzf = {},
					themes = {
						layout_config = {
							horizontal = {
								width = 0.8,
								height = 0.7,
							},
						},
					}
				}
			}

			telescope.load_extension('fzf')
			telescope.load_extension('themes')

			vim.keymap.set("n", "<space>fh", require('telescope.builtin').help_tags)
			vim.keymap.set("n", "<space>fd", require('telescope.builtin').find_files)
			vim.keymap.set("n", "<space>gs", require('telescope.builtin').git_status)
			vim.keymap.set('n', '<leader>fm', function()
				require('telescope.builtin').lsp_document_symbols({
					symbols = { "function", "method" },
				})
			end, { desc = '[F]ind [S]ymbols (LSP Functions/Methods)' })
			vim.keymap.set("n", "<space>en", function()
				require('telescope.builtin').find_files({
					cwd = vim.fn.stdpath("config")
				})
			end)
			vim.keymap.set("n", "<leader>ft", ":Telescope themes<CR>",
				{ noremap = true, silent = true, desc = "Theme Switcher" })

			require("config.telescope.multigrep").setup()
		end
	}
}
