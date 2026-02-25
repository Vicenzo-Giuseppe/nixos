return {
	"nyoom-engineering/oxocarbon.nvim",
	name = "oxocarbon",
	-- Prioridade alta para carregar o tema antes de outros plugins
	priority = 1000,
	config = function()
		-- Ativa o colorscheme
		vim.cmd.colorscheme("oxocarbon")
	end,
}
