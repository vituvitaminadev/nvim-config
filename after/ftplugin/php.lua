local set = vim.opt_local

set.tabstop = 4
set.shiftwidth = 4
set.number = true
set.relativenumber = true
set.expandtab = true

-- O indentexpr do treesitter é definido em config/plugins/treesitter.lua,
-- não aqui: after/ftplugin/php.lua roda ANTES de indent/php.vim (que seta
-- GetPhpIndent()), então um override aqui seria sobrescrito logo em
-- seguida. Ver o comentário lá pra mais contexto.
