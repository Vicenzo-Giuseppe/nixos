local ai = require("plugins.statusline.components.ai")
local debug = require("plugins.statusline.components.debug")
local edgy = require("plugins.statusline.components.edgy")
local git = require("plugins.statusline.components.git")
local info = require("plugins.statusline.components.info")
local mode = require("plugins.statusline.components.mode")
local system = require("plugins.statusline.components.system")
local tasks = require("plugins.statusline.components.tasks")

local Left = { mode.ViMode, git.Git, info.LazyUpdates, info.Separator, debug.Dap, debug.Molten, debug.MacroRec }
local Center = { info.Separator, info.Separator }
local Align = { provider = "%=", hl = { bg = "none" } }
local SystemStats = {
	mode.PrimarySpace,
	system.CPU,
	system.GPU,
	system.Memory,
}
local Right = {
	-- tasks.Overseer,
	info.LspProgress,
	-- ai.Sidekick,
	-- ai.Copilot,
	-- ai.CodeCompanion,
	--SystemStats,
	-- info.SearchCount,
	info.Separator,
	info.Date,
}

return { Left, Center, Align, Right }
