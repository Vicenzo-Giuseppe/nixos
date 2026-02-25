return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			-- Remove ktlint from the auto-install list
			opts.ensure_installed = vim.tbl_filter(function(v)
				return v ~= "ktlint"
			end, opts.ensure_installed or {})
		end,
	},
	-- Override Formatting (Conform)
	{
		"stevearc/conform.nvim",
		opts = {
			formatters = {
				ktlint = {
					-- Set the absolute path if it's not in your $PATH
					command = "ktlint",
				},
			},
		},
	},

	-- Override Linting (nvim-lint)
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters = {
				ktlint = {
					cmd = "ktlint", -- Change this to the full path if needed
				},
			},
		},
	},
}
