return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
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
			local lspconfig = require('lspconfig')
			local util = require('lspconfig').util

			-- vim.lsp.config('lua_ls', {
			-- 	capabilities = capabilities,
			-- })

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})

			-- vim.lsp.config('phpactor', {
			-- 	capabilities = capabilities,
			-- 	cmd = { 'phpactor', 'language-server' },
			-- 	filetypes = { 'php' },
			-- 	root_dir = util.root_pattern("composer.json", ".git"),
			-- })

			-- lspconfig.phpactor.setup({
			-- 	capabilities = capabilities,
			-- 	cmd = { 'phpactor', 'language-server' },
			-- 	filetypes = { 'php' },
			-- 	root_dir = util.root_pattern("composer.json", ".git"),
			-- })

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

			-- vim.lsp.config('intelephense', {
			-- 	capabilities = capabilities,
			-- 	cmd = { 'intelephense', '--stdio' },
			-- 	filetypes = { 'php' },
			-- 	stubs = {
			-- 		"hyperf",
			-- 		"pdo",
			-- 		"json",
			-- 		"curl",
			-- 		"mbstring",
			-- 		"openssl",
			-- 		"dom",
			-- 		"fileinfo",
			-- 	},
			-- 	environment = {
			-- 		includePaths = { "/path/to/your/hyperf/vendor" },
			-- 	},
			-- })

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

					if client.name == 'phpactor' then
						vim.keymap.set('n', '<leader>pc', function()
							local current_file = vim.fn.expand('%:p:h')
							local project_root = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()

							-- Calcular caminho relativo da pasta app/
							local app_path = project_root .. '/app'
							local relative_path = ''

							if current_file:find(app_path, 1, true) then
								relative_path = current_file:gsub(vim.pesc(app_path .. '/'), '')
							end

							local suggestion = relative_path ~= '' and relative_path .. '/' or ''
							local class_input = vim.fn.input('Class name: ', suggestion)

							if class_input == '' then return end

							-- Remove .php e barras finais
							class_input = class_input:gsub('%.php$', ''):gsub('/$', '')

							-- Separar em partes para criar namespace e nome da classe
							local parts = vim.split(class_input, '/')
							local class_name = parts[#parts]
							table.remove(parts, #parts)

							-- Construir namespace
							local namespace = 'App'
							if #parts > 0 then
								namespace = namespace .. '\\' .. table.concat(parts, '\\')
							end

							-- Caminho completo do arquivo
							local file_path = app_path .. '/' .. class_input .. '.php'
							local dir_path = vim.fn.fnamemodify(file_path, ':h')

							-- Criar diretórios se necessário
							vim.fn.mkdir(dir_path, 'p')

							-- Template da classe
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

							-- Escrever arquivo
							vim.fn.writefile(template, file_path)

							-- Abrir arquivo
							vim.cmd('edit ' .. file_path)

							-- Posicionar cursor dentro da classe
							vim.api.nvim_win_set_cursor(0, { 9, 4 })

							vim.notify('✅ Classe criada: ' .. namespace .. '\\' .. class_name, vim.log.levels.INFO)

							-- Reindexar phpactor
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
											vim.notify("✅ PHPActor reindexed!", vim.log.levels.INFO)
										end)
									else
										vim.notify("❌ Reindex failed!", vim.log.levels.ERROR)
									end
								end
							})
							vim.notify("🔄 Reindexing PHPActor...", vim.log.levels.INFO)
						end, { buffer = args.buf, desc = "PHPActor Reindex" })
					end
				end
			})
		end,
	}
}
