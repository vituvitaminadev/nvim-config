return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require('nvim-treesitter').setup({
				install_dir = vim.fn.stdpath('data') .. '/site',
			})

			require('nvim-treesitter').install({
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"php",
				"vue",
				"typescript",
				"javascript",
				"tsx",
				"css",
				"scss",
				"html",
				"json",
				"yaml",
			})

			vim.api.nvim_create_autocmd('FileType', {
				pattern = {
					"c", "lua", "vim", "query", "markdown", "php",
					"vue", "typescript", "javascript", "typescriptreact",
					"css", "scss", "html", "json", "jsonc", "yaml",
				},
				callback = function()
					pcall(vim.treesitter.start)

					-- "php" usa o highlighting do treesitter, mas precisa de
					-- indentexpr próprio: vim.treesitter.start() desliga o
					-- :syntax clássico, e o script de indentação nativo
					-- (GetPhpIndent(), em runtime/indent/php.vim) depende
					-- dele pra entender o contexto do código. Esse override
					-- só funciona AQUI (e não em after/ftplugin/php.lua)
					-- porque este autocmd roda depois de indent/php.vim ter
					-- setado o indentexpr padrão — setar mais cedo seria
					-- sobrescrito.
					if vim.bo.filetype == "php" then
						vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
					end
				end,
			})
		end
	}
}
