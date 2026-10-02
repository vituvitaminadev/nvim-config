return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({})

		-- Keymaps básicos
		-- Adicionar arquivo à lista
		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
		vim.keymap.set("n", "<leader>r", function() harpoon:list():remove() end, { desc = "Harpoon: Add file" })

		-- Abrir a UI nativa do Harpoon (Menu editável)
		vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
			{ desc = "Harpoon: Open Menu" })

		-- Atalhos para saltar direto para os arquivos (Slots 1 a 4)
		vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
		vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
		vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
		vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)

		-- Navegação sequencial (Opcional)
		vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
		vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
	end,
}
