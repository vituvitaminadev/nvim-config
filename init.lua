require("config.lazy")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":.lua<CR>")

vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCodeContinue<CR>", { desc = "Toggle Claude Code" })

vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
vim.keymap.set("n", "grr", vim.lsp.buf.references)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

vim.keymap.set("n", "<leader>cs", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header" })

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({
		lsp_fallback = true,
		timeout_ms = 1000,
	})
end, { desc = "Formatar arquivo" })

vim.keymap.set("n", "-", "<cmd>Oil<CR>")

vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = true,
	severity_sort = false,
	float = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
