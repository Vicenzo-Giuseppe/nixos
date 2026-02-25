return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	ft = { "markdown", "codecompanion" },
	config = function()
		require("markview").setup({
			html = {
				enable = true,
			},
			hybrid_mode = true,
			hover = {
				enable = true,
				-- Set to true if you want markview to style the LSP hover window
			},
			preview = {
				enable = true, -- use <leader>tp to toggle
				filetypes = { "markdown", "codecompanion" },
				icon_provider = "mini", -- "internal", "mini" or "devicons"
			},
		})
	end,
}
