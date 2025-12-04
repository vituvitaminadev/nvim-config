require("config.lazy")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":.lua<CR>")

vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)

vim.keymap.set("n", "-", "<cmd>Oil<CR>")

vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.clipboard = "unnamedplus"
vim.wo.relativenumber = true

vim.diagnostic.config({
	virtual_text = true, -- mostra erro no final da linha
	signs = true,       -- mostra símbolos na coluna lateral
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = 'minimal',
		border = 'rounded',
		source = true,
		header = '',
		prefix = '',
	},
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
