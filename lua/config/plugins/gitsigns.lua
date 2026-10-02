return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add          = { text = '┃' },
			change       = { text = '┃' },
			delete       = { text = '_' },
			topdelete    = { text = '‾' },
			changedelete = { text = '~' },
			untracked    = { text = '┆' },
		},
		current_line_blame = true,

		-- Configuração das keybinds dentro do on_attach
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navegação entre alterações (Hunks)
			map('n', ']h', function()
				if vim.wo.diff then return ']h' end
				vim.schedule(function() gs.next_hunk() end)
				return '<Ignore>'
			end, { expr = true, desc = "Próximo Hunk" })

			map('n', '[h', function()
				if vim.wo.diff then return '[h' end
				vim.schedule(function() gs.prev_hunk() end)
				return '<Ignore>'
			end, { expr = true, desc = "Hunk Anterior" })

			-- Ações estilo IDE
			map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview da alteração" })
			map('n', '<leader>hr', gs.reset_hunk, { desc = "Resetar alteração (Hunk)" })
			map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage alteração (Hunk)" })
			map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage arquivo inteiro" })
			map('n', '<leader>hR', gs.reset_buffer, { desc = "Resetar arquivo inteiro" })
			map('n', '<leader>hd', gs.diffthis, { desc = "Ver Diff do arquivo" })

			-- Blame detalhado em janela flutuante
			map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = "Blame detalhado" })

			-- Atalhos para Visual Mode (resetar/stage blocos selecionados)
			map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
				{ desc = "Stage seleção" })
			map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
				{ desc = "Reset seleção" })
		end
	}
}
