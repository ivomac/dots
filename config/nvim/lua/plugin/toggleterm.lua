return {

	{
		"akinsho/toggleterm.nvim",
		opts = {
			open_mapping = nil,
			shade_terminals = false,
			start_in_insert = true,
			persist_mode = false,
			insert_mappings = false,
			terminal_mappings = false,
			close_on_exit = true,
			direction = "float",
			float_opts = {
				border = "rounded",
				width = function() return math.floor(0.92*vim.o.columns) end,
				height = function() return math.floor(0.92*vim.o.lines) end,
				row = 1,
				title_pos = "center",
			},
			winbar = {
				enabled = true,
				name_formatter = function(term)
					return term.name
				end
			},
		},
	},

}
