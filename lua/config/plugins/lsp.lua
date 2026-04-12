return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim", "love" },
							},
						},
					},
				},
				intelephense = {},
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
					gofumpt = true,
				},
				clangd = {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				},
			},
		},
		config = function(_, opts)
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"intelephense",
					"gopls",
					"stylua",
					"clangd",
				},
				automatic_installation = true,
			})

			vim.diagnostic.config({
				virtual_text = true,
				underline = true,
			})

			local on_attach = function(client, bufnr)
				local opts_key = { buffer = bufnr, silent = true }

				if client.name == "clangd" then
					vim.api.nvim_buf_create_user_command(bufnr, "ClangdSwitchSourceHeader", function()
						client.request("textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
							if err then
								return
							end
							if not result then
								print("Arquivo correspondente não encontrado")
								return
							end
							vim.api.nvim_command("edit " .. vim.uri_to_fname(result))
						end)
					end, { desc = "Switch between source and header" })

					vim.keymap.set(
						"n",
						"<leader>cs",
						"<cmd>ClangdSwitchSourceHeader<cr>",
						{ buffer = bufnr, desc = "Switch Header/Source" }
					)
				end
			end

			for server, config in pairs(opts.servers) do
				vim.api.nvim_create_autocmd("LspAttach", {
					callback = function(args)
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						if client and client.name == server then
							on_attach(client, args.buf)
						end
					end,
				})
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end,
	},
}
