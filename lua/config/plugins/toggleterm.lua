return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			-- Tamanho dinâmico baseado na direção
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,

			-- Atalho principal: Ctrl + \
			open_mapping = [[<c-\>]],

			hide_numbers = true,
			shade_terminals = true,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'

			close_on_exit = true,
			shell = vim.o.shell, -- Garante que usa o Fish, já que é o seu padrão

			float_opts = {
				border = 'curved', -- Borda arredondada estilosa
				winblend = 3,
			},
		})
	end
}
