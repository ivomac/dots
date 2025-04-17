
local fzf_fd_command = os.getenv("FZF_FD_COMMAND") or "fd "
local fzf_rg_command = os.getenv("FZF_RG_COMMAND") or "rg "

-- remove "fd" and "rg" from beginning of the commands

fzf_fd_command = fzf_fd_command:gsub("^fd ", "") .. " --type f"
fzf_rg_command = fzf_rg_command:gsub("^rg ", "") .. " --files"


return {

	{
		"mikavilpas/yazi.nvim",
		keys = {
			{ "<leader>a", function() vim.cmd.Yazi() end, desc = "File explorer" },
			{ "<leader>s", function() vim.cmd.Yazi("toggle") end, desc = "File explorer (session)" },
		},
	},

	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			files = {
				fd_opts = fzf_fd_command,
				rg_opts = fzf_rg_command,
			},
		},
		keys = {
			{ "<leader><leader>", function() require("fzf-lua").resume() end,                        silent = true, desc = "Last FZF" },
			{ "<leader>f",       function() require("fzf-lua").files() end,                          silent = true, desc = "Files" },
			{ "<leader>o",       function() require("fzf-lua").oldfiles({ resume = true }) end,      silent = true, desc = "Opened Files" },
			{ "<leader>h",       function() require("fzf-lua").git_files() end,                      silent = true, desc = "Git Files" },
			{ "<leader>l",       function() require("fzf-lua").live_grep() end,                      silent = true, desc = "Live Grep" },
			{ "<leader>L",       function() require("fzf-lua").grep() end,                           silent = true, desc = "Grep" },
			{ "<leader>L",       function() require("fzf-lua").grep_visual() end,                    silent = true, desc = "Grep Visual", mode = "x" },
			{ "<leader>K",       function() require("fzf-lua").helptags() end,                       silent = true, desc = "Help Tags" },
			{ "<leader>b",       function() require("fzf-lua").buffers() end,                        silent = true, desc = "Buffers" },
			{ "<leader>q",       function() require("fzf-lua").quickfix() end,                       silent = true, desc = "Quickfix" },
		},
	},

}
