local fzf_fd_command = os.getenv("FZF_FD_COMMAND") or "fd "
local fzf_rg_command = os.getenv("FZF_RG_COMMAND") or "rg "

-- remove "fd" and "rg" from beginning of the commands

fzf_fd_command = fzf_fd_command:gsub("^fd ", "") .. " --type f"
fzf_rg_command = fzf_rg_command:gsub("^rg ", "") .. " --files"


return {

	{
		"rmagatti/auto-session",
		lazy = false,
		keys = {
			{ "<leader>sf", "<cmd>Autosession search<CR>",    desc = "Search" },
			{ "<leader>sd", "<cmd>Autosession delete<CR>",    desc = "Delete" },
			{ "<leader>ss", "<cmd>SessionSave<CR>",           desc = "Save" },
			{ "<leader>sr", "<cmd>SessionRestore<CR>",        desc = "Restore" },
			{ "<leader>sa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
		},
		opts = {
			enabled = true,
			root_dir = vim.fn.expand("~") .. "/Docs/.nvim/sessions",
			auto_save = true,
			auto_restore = false,
			auto_create = false,
			auto_restore_last_session = false,
			git_use_branch_name = true,
			git_auto_restore_on_branch_change = true,
			lazy_support = true,
			close_unsupported_windows = true,
			args_allow_single_directory = true,
			args_allow_files_auto_save = true,
			continue_restore_on_error = false,
			show_auto_restore_notif = true,
			log_level = "error",
			session_lens = {
				load_on_setup = false,
			},
		}
	},

	{
		"ibhagwan/fzf-lua",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf = require("fzf-lua")
			fzf.setup({
				files = {
					fd_opts = fzf_fd_command,
					rg_opts = fzf_rg_command,
				},
				winopts = {
					width = 0.95,
					height = 0.95,
					row = 1.01,
					backdrop = 100,
					preview = {
						wrap = true,
						delay = 100,
						winopts = {
							number         = false,
							relativenumber = false,
							cursorline     = true,
							cursorlineopt  = "both",
							cursorcolumn   = false,
							signcolumn     = "yes:1",
							list           = false,
							foldenable     = false,
							foldmethod     = "manual",
						},
					},
				},
			})

			fzf.register_ui_select()

			vim.keymap.set("n", "<leader><leader>", fzf.resume, { silent = true, desc = "Last FZF" })

			vim.keymap.set("n", "<leader>fb", fzf.buffers, { silent = true, desc = "Buffers" })
			vim.keymap.set("n", "<leader>fa", fzf.files, { silent = true, desc = "All Files" })
			vim.keymap.set("n", "<leader>fq", fzf.quickfix, { silent = true, desc = "Quickfix" })
			vim.keymap.set("n", "<leader>fQ", fzf.quickfix_stack, { silent = true, desc = "Quickfix stack" })

			vim.keymap.set("n", "<leader>fS", fzf.grep, { silent = true, desc = "Search" })
			vim.keymap.set("x", "<leader>fs", fzf.grep_visual, { silent = true, desc = "Search visual" })
			vim.keymap.set("n", "<leader>fs", fzf.live_grep_native, { silent = true, desc = "Search Live" })

			vim.keymap.set("n", "<leader>gc", fzf.git_commits, { silent = true, desc = "Git commits" })

			vim.keymap.set("n", "<leader>gad", fzf.lsp_workspace_diagnostics, { silent = true, desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>gal", fzf.lsp_code_actions, { silent = true, desc = "Action list" })

			vim.keymap.set("n", "<leader>gsd", fzf.lsp_definitions, { silent = true, desc = "Symb definitions" })
			vim.keymap.set("n", "<leader>gsD", fzf.lsp_declarations, { silent = true, desc = "Symb declarations" })
			vim.keymap.set("n", "<leader>gst", fzf.lsp_typedefs, { silent = true, desc = "Symb type" })
			vim.keymap.set("n", "<leader>gsi", fzf.lsp_implementations, { silent = true, desc = "Symb implementations" })
			vim.keymap.set("n", "<leader>gsr", fzf.lsp_references, { silent = true, desc = "Symb references" })

			vim.keymap.set("n", "<leader>gss", fzf.lsp_live_workspace_symbols, { silent = true, desc = "All Symbs" })

			vim.keymap.set("n", "<leader>gsuc", fzf.lsp_outgoing_calls, { silent = true, desc = "Symb calling" })
			vim.keymap.set("n", "<leader>gslc", fzf.lsp_incoming_calls, { silent = true, desc = "Symb called by" })

			vim.keymap.set("n", "<leader>fK", fzf.helptags, { silent = true, desc = "Help Tags" })
			vim.keymap.set("n", "<leader>fu", fzf.changes, { silent = true, desc = "Changes" })

			vim.keymap.set("n", "<leader>db", fzf.dap_breakpoints, { silent = true, desc = "List Breakpoints" })
			vim.keymap.set("n", "<leader>dv", fzf.dap_variables, { silent = true, desc = "List Variables" })
		end,
	},

}
