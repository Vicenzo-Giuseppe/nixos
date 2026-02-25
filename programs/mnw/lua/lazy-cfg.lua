-- mnw is a global set by mnw
vim.g.mapleader = " "
-- so if it's set this config is being ran from nix
if mnw ~= nil then
	-- Thank you https://nixalted.com/lazynvim-nixos.html
	require("lazy").setup({
		dev = {
			path = mnw.configDir .. "/pack/mnw/opt",
			-- match all plugins
			patterns = { "" },
			-- fallback to downloading plugins from git
			-- disable this to force only using nix plugins
			fallback = true,
		},

		-- keep rtp/packpath the same
		performance = {
			reset_packpath = false,
			rtp = {
				reset = false,
			},
		},

		install = {
			-- install missing plugins
			missing = true,
		},

		spec = {
			-- add LazyVim and import its plugins
			{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
			{ import = "lazyvim.plugins.extras.dap.core" },
			{ import = "lazyvim.plugins.extras.lang.kotlin" },
			{ import = "lazyvim.plugins.extras.lang.nix" },
			--{ import = "lazyvim.plugins.extras.ui.edgy " },
			-- 2. Prevent Mason from trying to manage Kotlin
			-- import/override with your plugins
			{ import = "plugins", dev = true },
		},
	})
else
	-- otherwise we have to bootstrap lazy ourself
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		local lazyrepo = "https://github.com/folke/lazy.nvim.git"
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
		if vim.v.shell_error ~= 0 then
			vim.api.nvim_echo({
				{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
				{ out, "WarningMsg" },
				{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
			os.exit(1)
		end
	end
	vim.opt.rtp:prepend(lazypath)

	require("lazy").setup({
		spec = {
			-- add LazyVim and import its plugins
			{ import = "lazyvim.plugins.extras.dap.core" },
			--{ import = "lazyvim.plugins.extras.ui.edgy " },
			{ import = "lazyvim.plugins.extras.lang.kotlin" },
			{ import = "lazyvim.plugins.extras.lang.nix" },
			{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
			-- 2. Prevent Mason from trying to manage Kotlin
			{ import = "plugins", dev = true },
		},
	})
end
