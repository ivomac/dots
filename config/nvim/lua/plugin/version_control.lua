return {

	{
		"simnalamburt/vim-mundo",
		cmd = { "MundoToggle" },
		keys = {
			{ "<leader>u", vim.cmd.MundoToggle, desc = "UndoTree" },
		},
	},

	{ "nvim-tree/nvim-web-devicons" },

	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			local signs = require("gitsigns")
			signs.setup({
				signcolumn = true,
				signs = {
					add          = { text = "█" },
					change       = { text = "█" },
					topdelete    = { text = "🬂" },
					delete       = { text = "▂" },
					changedelete = { text = "█" },
					untracked    = { text = "▒" },
				},
				signs_staged = {
					add          = { text = "▌" },
					change       = { text = "▌" },
					topdelete    = { text = "🬀" },
					delete       = { text = "🬏" },
					changedelete = { text = "▌" },
				},
			})

			vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GruvboxGreenSign" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { link = "GruvboxBlueSign" })
			vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GruvboxPurpleSign" })
			vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "GruvboxRedSign" })

			vim.api.nvim_set_hl(0, "GitSignsStagedAdd", { link = "GitSignsAdd" })
			vim.api.nvim_set_hl(0, "GitSignsStagedChange", { link = "GitSignsChange" })
			vim.api.nvim_set_hl(0, "GitSignsStagedDelete", { link = "GitSignsDelete" })
			vim.api.nvim_set_hl(0, "GitSignsStagedChangedelete", { link = "GitSignsChangedelete" })

			vim.api.nvim_set_hl(0, "GitSignsUntracked", { link = "GruvboxGray" })


			vim.keymap.set({ "o", "x" }, "ah", signs.select_hunk, { silent = true, desc = "A hunk" })

			vim.keymap.set("n", "[h", function() signs.nav_hunk("prev") end, { silent = true, desc = "Previous hunk" })
			vim.keymap.set("n", "]h", function() signs.nav_hunk("next") end, { silent = true, desc = "Next hunk" })

			vim.keymap.set("n", "ghB", signs.blame, { silent = true, desc = "Blame column" })
			vim.keymap.set("n", "ghb", signs.blame_line, { silent = true, desc = "Blame line" })
			vim.keymap.set("n", "ghh", signs.preview_hunk_inline, { silent = true, desc = "Preview hunk" })
			vim.keymap.set("n", "ghp", signs.preview_hunk, { silent = true, desc = "Preview hunk popup" })
			vim.keymap.set("n", "ghq", function() signs.setqflist("all") end, { silent = true, desc = "Changes" })
			vim.keymap.set({ "n", "x" }, "ghr", signs.reset_hunk, { silent = true, desc = "Reset hunk" })
			vim.keymap.set({ "n", "x" }, "ghs", signs.stage_hunk, { silent = true, desc = "Stage hunk" })
			vim.keymap.set("n", "ghw", signs.toggle_word_diff, { silent = true, desc = "Word diff" })
			vim.keymap.set("n", "ghd", signs.diffthis, { silent = true, desc = "Diff file" })
		end,
	},

}
