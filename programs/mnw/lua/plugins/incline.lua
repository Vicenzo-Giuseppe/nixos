local separator_char = "-"
local unfocused = "NonText"
local focused = "Comment"

local icons = {
	ERROR = " ",
	WARN = " ",
	HINT = " ",
	INFO = " ",
}

local git_icons = {
	added = " ",
	modified = " ",
	removed = " ",
}

local function get_diagnostic_label(props)
	local label = {}
	local severities = { "ERROR", "WARN", "HINT", "INFO" }

	for _, severity in ipairs(severities) do
		local icon = icons[severity]
		local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity] })
		if n > 0 then
			table.insert(
				label,
				{ icon .. n .. " ", group = props.focused and "DiagnosticSign" .. severity or unfocused }
			)
		end
	end
	return label
end

local function get_git_diff(props)
	local icons = { removed = git_icons.removed, changed = git_icons.modified, added = git_icons.added }
	local highlight = { removed = "GitSignsDelete", changed = "GitSignsChange", added = "GitSignsAdd" }
	local labels = {}
	local ok, signs = pcall(vim.api.nvim_buf_get_var, props.buf, "gitsigns_status_dict")
	if ok then
		for name, icon in pairs(icons) do
			if tonumber(signs[name]) and signs[name] > 0 then
				table.insert(labels, {
					icon .. signs[name] .. " ",
					group = props.focused and highlight[name] or unfocused,
				})
			end
		end
	end
	return labels
end

local function get_toggleterm_id(props)
	local id = " " .. vim.fn.bufname(props.buf):sub(-1) .. " "
	return { { id, group = props.focused and "FloatTitle" or "Title" } }
end

local function is_toggleterm(bufnr)
	return vim.bo[bufnr].filetype == "toggleterm"
end
local function is_codecompanion(bufnr)
	return vim.bo[bufnr].filetype == "codecompanion"
end
local function is_avante(bufnr)
	return vim.bo[bufnr].filetype:sub(0, 6) == "Avante"
end

local edgy_filetypes = {
	"neotest-output-panel",
	"neotest-summary",
	"noice",
	"Trouble",
	"OverseerList",
	"Outline",
	"trouble",
	"copilot-chat",
	"aerial",
}

local edgy_titles = {
	["neotest-output-panel"] = "neotest",
	["neotest-summary"] = "neotest",
	noice = "",
	Trouble = "trouble",
	OverseerList = "overseer",
	Outline = "outline",
	aerial = "aerial",
}

local function is_edgy_group(props, filename)
	return vim.tbl_contains(edgy_filetypes, vim.bo[props.buf].filetype)
end

local function get_trouble_name(props)
	local win_trouble = vim.w[props.win].trouble
	local trouble_name = win_trouble and win_trouble.mode or ""
	return trouble_name == "" and "trouble" or trouble_name
end

local function get_title(props, filename)
	local filetype = vim.bo[props.buf].filetype
	local name = edgy_titles[filetype] or filetype or filename
	name = filetype == "trouble" and get_trouble_name(props) or name
	local title = " " .. name .. " "
	return { { title, group = props.focused and "FloatTitle" or "Title" } }
end

local function get_avante_title(props)
	-- Parse filetype from CamelCase to snake-case
	local filetype = vim.bo[props.buf].filetype
	local title = " " .. filetype
		:gsub("(%u)", function(c)
			return "-" .. c:lower()
		end)
		:sub(2) .. " "
	return { { title, group = props.focused and "FloatTitle" or "Title" } }
end

local function get_search_count(props)
	if vim.v.hlsearch == 0 then
		return {}
	end

	if props.buf ~= vim.api.nvim_get_current_buf() then
		return {}
	end

	local ok, search = pcall(vim.fn.searchcount)
	if not ok or not search.total then
		return {}
	end

	local search_text = string.format("[%d/%d] ", search.current, math.min(search.total, search.maxcount))
	return { { search_text, group = props.focused and "Identifier" or unfocused } }
end

return {
	"b0o/incline.nvim",
	event = "BufEnter",
	keys = {
		{
			"<leader>uo",
			function()
				if require("incline").is_enabled() then
					vim.notify("Disabled Incline", vim.log.levels.WARN, { title = "Incline" })
				else
					vim.notify("Enabled Incline", vim.log.levels.INFO, { title = "Incline" })
				end
				require("incline").toggle()
			end,
			desc = "Toggle incline",
		},
	},
	opts = {
		debounce_threshold = { rising = 50, falling = 50 },
		window = {
			zindex = 30,
			margin = {
				vertical = { top = 0, bottom = 0 }, -- shift to overlap window borders
				horizontal = { left = 0, right = 2 }, -- shift for scrollbar
			},
			overlap = {
				borders = true,
				statusline = true,
				tabline = false,
				winbar = true,
			},
		},
		hide = {
			cursorline = false,
		},
		ignore = {
			buftypes = {},
			filetypes = { "neo-tree", "dashboard", "snacks_dashboard", "neominimap" },
			unlisted_buffers = false,
		},
		render = function(props)
			local devicons = require("nvim-web-devicons")

			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
			if filename == "" then
				filename = "[No Name]"
			end
			local ft_icon, ft_color = devicons.get_icon_color(filename)

			if is_toggleterm(props.buf) then
				return get_toggleterm_id(props)
			end

			if is_edgy_group(props, filename) then
				return get_title(props, filename)
			end

			if is_avante(props.buf) then
				return get_avante_title(props)
			end

			local diagnostics = get_diagnostic_label(props)
			local diffs = get_git_diff(props)
			local search_count = get_search_count(props)

			local color = props.focused and focused or unfocused
			local separator = (#diagnostics > 0 and (#diffs > 0 or #search_count > 0))
					and { separator_char .. " ", group = color }
				or ""
			local search_separator = (#diffs > 0 and #search_count > 0) and { separator_char .. " ", group = color }
				or ""
			local buffer = {
				{ (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
				{ filename .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
				{ diagnostics },
				{ separator },
				{ diffs },
				{ search_separator },
				{ search_count },
			}
			return buffer
		end,
	},
	config = function(_, opts)
		require("incline").setup(opts)
	end,
}
