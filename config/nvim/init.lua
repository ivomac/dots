vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local imports = {
	{ import = "plugin" },
}

if vim.g.started_by_firenvim then
	imports = {
		{
			"glacambre/firenvim",
			lazy = false,
			build = ":call firenvim#install(0)",
			config = function()
				vim.g.firenvim_config = {
					globalSettings = { alt = "all" },
					localSettings = {
						[".*"] = {
							cmdline  = "firenvim",
							priority = 0,
							takeover = "never"
						}
					}
				}
			end,
		}
	}
end

require("lazy").setup(
	imports,
	{
		install = { colorscheme = { "gruvbox" } },
		debug = false,
		defaults = { lazy = true },
		change_detection = { enabled = false },
		checker = { enabled = false },
		ui = { border = "rounded" },
		performance = {
			cache = {
				enabled = true,
			},
			rtp = {
				disabled_plugins = {
					"matchit",
					"matchparen",
					"netrwPlugin",
					"gzip",
					"tarPlugin",
					"tohtml",
					"tutor",
					"zipPlugin",
				},
			},
		},
	}
)

dofile(os.getenv("HOME") .. "/.local/colors/nvim/default.lua")
