vim.opt.background = "dark" -- set this to dark or light
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

vim.opt.number = true -- Mostra o número absoluto na linha atual
vim.opt.relativenumber = true -- Mostra a distância nas outras linhas
vim.g.mapleader = " "
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

-- 1. Habilita a statusline global (uma única barra no rodapé)
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.cmdheight = 0
vim.opt.showtabline = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = "codecompanion",
	callback = function()
		-- Pequeno delay para garantir que o buffer esteja pronto
		vim.defer_fn(function()
			if vim.cmd.Markview then
				vim.cmd("Markview attach")
				vim.cmd("Markview enable")
			end
		end, 50)
	end,
})
vim.g.maplocalleader = "." --
-- Enable snacks animations
vim.g.snacks_animate = true
