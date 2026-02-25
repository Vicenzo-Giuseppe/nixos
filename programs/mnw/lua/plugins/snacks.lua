return {
	"folke/snacks.nvim",
	opts = {},
	config = function(_, opts)
		vim.api.nvim_set_hl(0, "SnacksImageBorder", { fg = "#7aa2f7", bold = true })
		vim.api.nvim_set_hl(0, "SnacksImageBackground", { bg = "NONE" })

		local map = vim.keymap.set

		-- Explorer: Opens in edgy sidebar (left), simple layout
		-- map("n", "<leader>e", function()
		-- 	local snacks = require("snacks")
		-- 	local edgy = require("edgy")
		-- 	local Config = require("edgy.config")
		-- 	local left_bar = Config.layout.left
		--
		-- 	local pickers = snacks.picker.get({ source = "explorer" })
		-- 	if #pickers > 0 then
		-- 		pickers[1]:close()
		-- 		return
		-- 	end
		--
		-- 	if left_bar and #left_bar.wins == 0 then
		-- 		edgy.open("left")
		-- 		vim.defer_fn(function()
		-- 			if #snacks.picker.get({ source = "explorer" }) == 0 then
		-- 				-- Simple explorer, no preview
		-- 				snacks.explorer({ layout = { preset = "default", preview = false } })
		-- 			end
		-- 		end, 100)
		-- 	else
		-- 		snacks.explorer({ layout = { preset = "default", preview = false } })
		-- 	end
		-- end, { desc = "Explorer (Sidebar)" })
		--
		-- Other pickers: Open as floating (default behavior)
		map("n", "<leader><space>", function()
			require("snacks").picker.smart()
		end, { desc = "Smart Find Files (Float)" })

		map("n", "<leader>io", function()
			require("snacks").image.hover()
		end, { desc = "Image Hover" })

		map("n", "<leader>ic", function()
			require("snacks").image.clear()
			vim.cmd("redraw!")
		end, { desc = "Clear Images & Redraw" })

		vim.api.nvim_create_user_command("SnacksExplorer", function()
			require("snacks").explorer()
		end, { desc = "Open Snacks Explorer" })

		vim.api.nvim_set_hl(0, "SnacksImageBorder", { fg = "#7aa2f7" })
		require("snacks").setup(opts)
	end,
}
