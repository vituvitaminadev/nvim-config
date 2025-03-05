return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			'saghen/blink.cmp',
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			local capabilities = require('blink.cmp').get_lsp_capabilities()
			local util = require("lspconfig.util")

			require("lspconfig").lua_ls.setup {
				capabilities = capabilities,
			}

			require("lspconfig").phpactor.setup {
				capabilities = capabilities,
				cmd = { 'phpactor', 'language-server', '-vvv' },
				filetypes = { 'php' },
				root_dir = util.root_pattern("composer.json", ".git"),
			}

			require("lspconfig").intelephense.setup {
				capabilities = capabilities,
				stubs = {
					"hyperf",
					"pdo",
					"json",
					"curl",
					"mbstring",
					"openssl",
					"dom",
					"fileinfo",
				},
				environment = {
					-- includePaths = { "/path/to/your/hyperf/vendor" },
				},
			}

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then return end

					if client.supports_method('textDocument/formatting') then
						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = args.buf,
							callback = function()
								vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
								vim.diagnostic.enable(args.buf)
							end,
						})
					end
				end
			})
		end,
	}
}
