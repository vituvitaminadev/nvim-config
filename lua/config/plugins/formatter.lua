return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
        },

        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })

      -- Garante que o Mason bin esteja no PATH
      vim.env.PATH = vim.env.PATH
        .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
    end,
  },
}
