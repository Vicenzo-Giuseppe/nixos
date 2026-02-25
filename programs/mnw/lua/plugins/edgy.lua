return {
	"folke/edgy.nvim",
	lazy = false,
	dependencies = { "folke/snacks.nvim" },
	init = function()
		vim.opt.laststatus = 3
		vim.opt.splitkeep = "screen"
	end,
	opts = {
		top = {},
		left = {
			-- {
			-- 	title = "Snacks Explorer",
			-- 	ft = "snacks_picker_list",
			-- 	size = { width = 30 },
			-- 	pinned = true,
			-- 	open = function()
			-- 		-- Open edgy sidebar first (triggers animation)
			-- 		require("edgy").open("left")
			-- 		-- Delay snacks explorer creation until animation starts
			-- 		vim.defer_fn(function()
			-- 			local pickers = require("snacks").picker.get({ source = "explorer" })
			-- 			if #pickers == 0 then
			-- 				require("snacks").explorer()
			-- 			end
			-- 		end, 100)
			-- 	end,
			-- 	filter = function(buf, win)
			-- 		return vim.bo[buf].buftype == "nofile"
			-- 	end,
			-- },
			{
				title = "Tree",
				ft = "snacks_layout_box",
			},
			{
				title = "Lazy",
				ft = "lazy",
			},

			-- Opcional: Capturar também a caixa de input se ela for separada
			--[[
      {
        title = "Snacks Input",
        size = { height = 0.4 },
        ft = "snacks_picker_list",
      },
      ]]
		},
		right = {
			{
				title = "Outliner",
				ft = "Outline",
			},
			{
				title = "Trouble",
				ft = "trouble",
			},
			{
				title = "Agent",
				ft = "codecompanion",
			},

			--{
			--	ft = "image_preview",
			--	title = "Snacks Preview",
			--	size = { width = 0.4 }, -- Ocupa 40% da largura
			--	open = function()
			--		require("snacks").image.hover()
			--	end,
			--},
			{
				title = "Imagem",
				ft = "image",
			},
		},
		animate = {
			enabled = true,
			cps = 120,
		},
		bottom = {
			{
				ft = "snacks_terminal",
				title = "Terminal",
				filter = function(buf, win)
					return vim.api.nvim_win_get_config(win).relative == ""
				end,
			},
			{
				title = "gem",
				-- Filtro robusto para evitar erros de Lua em buffers vazios ou inválidos
				-- Implementação ultra-segura para evitar erros de buffer

				ft = "symbols",
			},
		},
	},
}
