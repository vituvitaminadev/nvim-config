return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			require("mason").setup()

			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls", "phpactor", "intelephense",
					"vue_ls", "vtsls", "cssls", "jsonls", "eslint",
				},
			})

			require("mason-tool-installer").setup({
				ensure_installed = { "prettierd" },
			})

			local capabilities = require('blink.cmp').get_lsp_capabilities()

			local mason_registry = require("mason-registry")
			local vue_language_server_path = mason_registry
				.get_package("vue-language-server")
				:get_install_path() .. "/node_modules/@vue/language-server"

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } }
					}
				}
			})

			vim.lsp.config("phpactor", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					client.server_capabilities.definitionProvider = false
					client.server_capabilities.implementationProvider = false
					client.server_capabilities.referencesProvider = false
					client.server_capabilities.typeDefinitionProvider = false
				end
			})

			vim.lsp.config("intelephense", {
				capabilities = capabilities,
				settings = {
					intelephense = {
						telemetry = { enabled = false },
						completion = { fullyQualifyImport = true },
						diagnostics = { unusedSymbols = true }, -- Para ver variáveis não usadas
						stubs = {
							"apache", "bcmath", "bz2", "calendar", "Core", "curl", "date", "dba", "dom", "enchant",
							"fileinfo", "filter", "ftp", "gd", "gettext", "hash", "iconv", "imap", "intl", "json",
							"ldap", "libxml", "mbstring", "mcrypt", "mysql", "mysqli", "password", "pcntl", "pcre",
							"PDO", "pdo_mysql", "Phar", "readline", "recode", "Reflection", "session", "SimpleXML",
							"soap", "sockets", "SPL", "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm",
							"tidy", "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter", "xsl", "zip", "zlib",
							"hyperf"
						},
					},
				},
			})

			vim.lsp.config("vtsls", {
				capabilities = capabilities,
				filetypes = {
					"javascript", "javascriptreact", "javascript.jsx",
					"typescript", "typescriptreact", "typescript.tsx", "vue",
				},
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								{
									name = "@vue/typescript-plugin",
									location = vue_language_server_path,
									languages = { "vue" },
									configNamespace = "typescript",
								},
							},
						},
					},
				},
			})

			vim.lsp.config("vue_ls", {
				capabilities = capabilities,
			})

			vim.lsp.config("cssls", {
				capabilities = capabilities,
			})

			vim.lsp.config("jsonls", {
				capabilities = capabilities,
			})

			vim.lsp.config("eslint", {
				capabilities = capabilities,
				workspace_required = true,
			})

			vim.lsp.enable({ "vtsls", "vue_ls", "cssls", "jsonls", "eslint", "phpactor", "intelephense" })

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then return end

					local bufnr = args.buf

					-- Filetypes formatados pelo conform/Prettier; LSP não deve formatá-los
					local conform_filetypes = {
						vue = true, typescript = true, javascript = true,
						typescriptreact = true, javascriptreact = true,
						css = true, scss = true, html = true,
						json = true, jsonc = true, yaml = true, markdown = true,
					}

					if client:supports_method('textDocument/formatting', { bufnr = bufnr }) then
						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = bufnr,
							callback = function()
								if conform_filetypes[vim.bo[bufnr].filetype] then return end
								vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
							end,
						})
					end

					if client.name == 'phpactor' then
						vim.keymap.set('n', '<leader>pc', function()
							local current_file = vim.fn.expand('%:p:h')
							local project_root = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()

							local app_path = project_root .. '/app'
							local relative_path = ''

							if current_file:find(app_path, 1, true) then
								relative_path = current_file:gsub(vim.pesc(app_path .. '/'), '')
							end

							local suggestion = relative_path ~= '' and relative_path .. '/' or ''
							local class_input = vim.fn.input('Class name: ', suggestion)

							if class_input == '' then return end

							class_input = class_input:gsub('%.php$', ''):gsub('/$', '')

							local parts = vim.split(class_input, '/')
							local class_name = parts[#parts]
							table.remove(parts, #parts)

							local namespace = 'App'
							if #parts > 0 then
								namespace = namespace .. '\\' .. table.concat(parts, '\\')
							end

							local file_path = app_path .. '/' .. class_input .. '.php'
							local dir_path = vim.fn.fnamemodify(file_path, ':h')

							vim.fn.mkdir(dir_path, 'p')

							local template = {
								'<?php',
								'',
								'declare(strict_types=1);',
								'',
								'namespace ' .. namespace .. ';',
								'',
								'class ' .. class_name,
								'{',
								'    ',
								'}',
								''
							}

							vim.fn.writefile(template, file_path)

							vim.cmd('edit ' .. file_path)

							vim.api.nvim_win_set_cursor(0, { 9, 4 })

							vim.notify('Classe criada: ' .. namespace .. '\\' .. class_name, vim.log.levels.INFO)

							vim.defer_fn(function()
								vim.cmd('LspRestart phpactor')
							end, 100)
						end, { buffer = args.buf, desc = "PHPActor Create Class" })

						vim.keymap.set('n', '<leader>pr', function()
							vim.fn.jobstart('phpactor index:build', {
								cwd = vim.fn.getcwd(),
								on_exit = function(_, exit_code)
									if exit_code == 0 then
										vim.schedule(function()
											vim.cmd('LspRestart phpactor')
											vim.notify("PHPActor reindexed!", vim.log.levels.INFO)
										end)
									else
										vim.notify("Reindex failed!", vim.log.levels.ERROR)
									end
								end
							})
							vim.notify("Reindexing PHPActor...", vim.log.levels.INFO)
						end, { buffer = args.buf, desc = "PHPActor Reindex" })
					end
				end
			})
		end,
	}
}
