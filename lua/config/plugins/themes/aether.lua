-- Plugin "motor" compartilhado por todos os temas baseados em aether.nvim.
-- Ele só registra um único colorscheme (:colorscheme aether); a paleta real
-- é escolhida em tempo de troca por current-theme.lua, que chama
-- require("aether").setup(require("aether-palettes.<nome>")) antes de
-- aplicar o colorscheme. Ver ~/.config/nvim/lua/aether-palettes/.
return {
	"bjarneo/aether.nvim",
	branch = "v3",
	name = "aether",
	lazy = false,
	priority = 1000,
	config = function()
		require("aether").setup(require("aether-palettes.reddcs"))
		require("aether.hotreload").setup()
	end,
}
