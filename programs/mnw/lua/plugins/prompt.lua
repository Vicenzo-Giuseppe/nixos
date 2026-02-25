return {
	"robcmills/prompt.nvim",
	config = function()
		require("prompt").setup({
			highlight_groups = {
				delineator_spinner = { link = "ErrorMsg" },
			},
			highlight_groups_by_role = {
				assistant = {
					delineator_icon = { fg = "cyan" },
					delineator_line = { link = "DiagnosticVirtualTextInfo" },
					delineator_role = {},
				},
				reasoning = {
					delineator_icon = {},
					delineator_line = { link = "DiagnosticVirtualTextHint" },
					delineator_role = {},
				},
				usage = {
					delineator_icon = {},
					delineator_line = { link = "DiffAdd" },
					delineator_role = {},
				},
				user = {
					delineator_icon = { fg = "orange" },
					delineator_line = { link = "DiagnosticVirtualTextWarn" },
					delineator_role = {},
				},
			},
			history_date_format = "%Y-%m-%dT%H:%M:%S",
			history_dir = "~/.local/share/nvim/prompt/history/",
			icons = {
				assistant = "●",
				reasoning = "∴",
				usage = "$",
				user = "○",
			},
			max_filename_length = 75,
			model = "anthropic/claude-sonnet-4",
			models_path = "~/.local/share/nvim/prompt/models.json",
			render_usage = function(usage)
				return string.format(
					"ADSADTokens: %d prompt + %d completion = %d total | Cost: $%.4f",
					usage.prompt_tokens,
					usage.completion_tokens,
					usage.total_tokens,
					usage.cost
				)
			end,
			spinner_chars = { "⠋", "⠙", "⠸", "⠴", "⠦", "⠇" },
			spinner_interval = 150,
			spinner_timeout = 1000,
		})
	end,
}
