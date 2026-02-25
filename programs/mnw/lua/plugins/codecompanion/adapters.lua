return {
	"olimorris/codecompanion.nvim",
	opts = {
		adapters = {
			copilot = function()
				return require("codecompanion.adapters").extend("copilot", {
					schema = { model = { default = "gpt-5-mini" } },
				})
			end,
			acp = {
				opencode = function()
					return require("codecompanion.adapters").extend("claude_code", {
						name = "opencode",
						formatted_name = "OpenCode",
						commands = {
							default = { "opencode", "acp" },
						},
					})
				end,
			},
		},
		---@type CodeCompanion.Interactions
		interactions = {
			cmd = { adapter = "copilot", model = "gpt-5-mini" },
			chat = { adapter = { name = "opencode" } },
			inline = { adapter = { name = "copilot", model = "gpt-5-mini" } },
		},
	},
}
