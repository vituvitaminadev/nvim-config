return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			'saghen/blink.cmp',
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
			local capabilities = require('blink.cmp').get_lsp_capabilities()
			local lspconfig = require('lspconfig')

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})

			lspconfig.intelephense.setup({
				capabilities = capabilities,
				cmd = { 'intelephense', '--stdio' },
				filetypes = { 'php' },
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
					includePaths = { "/path/to/your/hyperf/vendor" },
				},
				files = {
					maxSize = 5000000,
				},
				format = {
					enable = true,
				},
				diagnostics = {
					enable = true,
				},
				completion = {
					insertUseDeclaration = true,
					fullyQualifyGlobalConstantsAndFunctions = true
				},
			})

			lspconfig.phpactor.setup({
				capabilities = capabilities,
				cmd = { 'phpactor', 'language-server' },
				filetypes = { 'php' },
				root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
			})

			lspconfig.vtsls.setup({
				capabilities = capabilities,
				filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
				root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', '.git'),
				init_options = {
					plugins = {
						{
							name = '@vue/typescript-plugin',
							location = vim.fn.getcwd() .. '/node_modules/@vue/language-server',
							languages = { 'vue' },
						},
					},
				},
				settings = {
					vtsls = {
						experimental = {
							completion = {
								enableServerSideFuzzyMatch = true
							},
						},
						autoUseWorkspaceTsdk = true,
					},
					typescript = {
						preferences = {
							importModuleSpecifier = 'relative',
							includeInlayParameterNameHints = 'all',
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						updateImportsOnFileMove = { enabled = "always" },
						suggest = {
							autoImports = true,
							completeFunctionCalls = true,
						},
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						preferences = {
							importModuleSpecifier = 'relative',
						},
						updateImportsOnFileMove = { enabled = "always" },
						suggest = {
							autoImports = true,
							completeFunctionCalls = true,
						},
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			})

			lspconfig.eslint.setup({
				capabilities = capabilities,
				filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
				settings = {
					workingDirectory = { mode = "auto" },
				},
			})

			lspconfig.volar.setup({
				capabilities = capabilities,
				filetypes = { 'vue' },
				init_options = {
					typescript = {
						tsdk = vim.fn.getcwd() .. '/node_modules/typescript/lib'
					},
					vue = {
						hybridMode = true,
					},
				},
			})

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then return end

					local bufnr = args.buf

					if client.supports_method('textDocument/formatting') then
						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = bufnr,
							callback = function()
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
