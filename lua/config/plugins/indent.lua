return {
    "echasnovski/mini.indentscope",
    version = false, -- Usa a versão mais recente
    opts = {
        -- Caractere da linha vertical
        symbol = "│",
        options = {
            try_as_border = false,
        },
        -- Animação suave (pode desativar se preferir instantâneo)
        draw = {
            delay = 100,
            animation = function(s, n) return 20 end, -- Velocidade da animação
        },
    },
    config = function(_, opts)
        require("mini.indentscope").setup(opts)

        -- Customização de cores para combinar com o Cyberdream
        -- Vamos usar um tom de ciano/azul neon que é a marca do tema
        vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#5ef1ff", nocombine = true })
    end,
}
