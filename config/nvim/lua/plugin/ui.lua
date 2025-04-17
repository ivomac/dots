return {

	{
		"ellisonleao/gruvbox.nvim",
		config = function()
			require("gruvbox").setup({
				terminal_colors = true,
				transparent_mode = true,
			})
		end
	},

	{
		"romainl/vim-cool",
		event = "VeryLazy",
	},

	{
		"monkoose/matchparen.nvim",
		event = "VeryLazy",
		opts = {},
	},

	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			indent = {
				enable = true,
				priority = 0,
				use_treesitter = false,
				chars = { "│", "╎", "┆", "┊" },
				ahead_lines = 0,
				exclude_filetypes = {
					"help",
				},
			},
		}
	},

	{
		{
			"mattn/libcallex-vim",
			ft = { "markdown.graphics" },
			build = "make -C autoload",
		},
		{
			"gzqx/vim-graphical-preview",
			ft = { "markdown.graphics" },
			build = "cargo build --release"
		}
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			icons = { mappings = false },
			spec = {
				{ "<leader>", group = "Leader" },
				{ "<leader>a", group = "Actions" },
				{ "<leader>c", group = "Cd/Files" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>df", group = "Filetype Specific" },
				{ "<leader>f", group = "FZF" },
				{ "<leader>g", group = "FZF Lsp" },
				{ "<leader>ga", group = "FZF Lsp Actions" },
				{ "<leader>gs", group = "FZF Lsp Symbols" },
				{ "<leader>n", group = "Tests" },
				{ "<leader>s", group = "Session" },
				{ "<leader>t", group = "Terminal" },
				{ "<leader>tl", group = "LazyGit" },
				{ "[", group = "Previous…" },
				{ "]", group = "Next…" },
				{ "g", group = "GO!" },
				{ "ga", group = "LSP Actions" },
				{ "gh", group = "Hunk/Gitsigns" },
				{ "gs", group = "LSP Symbols" },
				{ "gsl", group = "Lower" },
				{ "gsu", group = "Upper" },
				{ "z", group = "Fold/Spelling" },
			}
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				component_separators = "",
				section_separators = "",
				theme = "gruvbox",
				globalstatus = true,
			},
			sections = {
				lualine_a = {},
				lualine_b = {
					{
						function()
							local session = require("auto-session.lib").current_session_name(true)
							if session ~= "" then
								session = session:gsub("^[^%a]*", ""):gsub("%s+%(branch:.+%)$", "")
								return string.format("[%s]", session)
							end
							return ""
						end,
						padding = { left = 1, right = 0 }
					},
					{ "filename", padding = { left = 1, right = 1 } },
					{ "filesize", padding = { left = 0, right = 1 } },
					{ "location", padding = { left = 0, right = 1 } },
					{ "progress", padding = { left = 0, right = 1 } },
				},
				lualine_c = {
					{
						function()
							return "%="
						end,
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
						},
						padding = { left = 1, right = 1 },
					},
				},
				lualine_x = {},
				lualine_y = {
					{
						function()
							local msg = ""
							local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
							local clients = vim.lsp.get_clients()
							for _, client in ipairs(clients) do
								local filetypes = client.config["filetypes"]
								if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
									return client.name
								end
							end
							return msg
						end,
						icon = "",
						padding = { left = 1, right = 0 },
					},
					{ "filetype", icon_only = true, colored = false, padding = { left = 1, right = 1 }, },
					{ "branch", icon = "", padding = { left = 0, right = 1 }, },
					{
						"diff",
						symbols = { added = " ", modified = "󰦓 ", removed = " " },
						colored = false,
						padding = { left = 0, right = 1 },
					}
				},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		},
	},

	{
		"luukvbaal/statuscol.nvim",
		lazy = false,
		config = function()
			require("statuscol").setup({
				segments = {
					{
						sign = {
							text = { ".*" },
							maxwidth = 1,
							colwidth = 1,
							auto = false,
							wrap = false,
						},
					},
				}
			})
		end,
	},

}
