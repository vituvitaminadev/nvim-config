require("config.lazy")
require("current-theme")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":.lua<CR>")

vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)

vim.keymap.set("n", "-", "<cmd>Oil<CR>")

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Abrir lista de erros" })

vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCodeContinue<CR>', { desc = 'Toggle Claude Code' })
vim.keymap.set('n', '<leader>lr', function()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("Nenhum LSP ativo para reiniciar", vim.log.levels.WARN)
		return
	end

	for _, client in ipairs(clients) do
		vim.lsp.stop_client(client.id)
	end

	vim.defer_fn(function()
		vim.cmd("edit!")
		vim.notify("LSPs reiniciados", vim.log.levels.INFO)
	end, 100)
end, { desc = 'Restart Lsps' })

vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true

vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN }
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
	},
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'qf',
	callback = function()
		vim.keymap.set('n', '<CR>', '<CR>:cclose<CR>', { buffer = true, silent = true })
	end,
})
