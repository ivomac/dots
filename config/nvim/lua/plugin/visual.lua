return {

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		dependencies = { "nvim-lualine/lualine.nvim" },
		opts = {
			terminal_colors = false,
			transparent_mode = true,
		}
	},

	{
		"machakann/vim-highlightedyank",
		config = function()
			vim.g.highlightedyank_highlight_duration = 120
		end,
	},

	{
		"Yggdroot/indentLine",
		config = function()
			vim.g.indentLine_char = ""
			vim.g.indentLine_char_list = { "|", "¦", "┆", "┊" }
			vim.g.indentLine_showFirstIndentLevel = 1
			vim.g.indentLine_first_char = "│"
			vim.g.indentLine_fileTypeExclude = { "json", "yaml", "markdown", "text", "help", "vim" }
		end,
	},

	{
		'kevinhwang91/nvim-ufo',
		dependencies = {
			'kevinhwang91/promise-async'
		},
	},
}
