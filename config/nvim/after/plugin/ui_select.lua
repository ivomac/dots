-- local hl_groups = {
-- 	{
-- 		name = "UIHint",
-- 		definition = { link = "Boolean" },
-- 	},
-- 	{
-- 		name = "UIFirstCol",
-- 		definition = {},
-- 	},
-- 	{
-- 		name = "UIOtherCol",
-- 		definition = { link = "Comment" },
-- 	},
-- }
--
-- local hl_ns = vim.api.nvim_create_namespace("UISelect")
--
-- for _, hl_group in pairs(hl_groups) do
-- 	vim.api.nvim_set_hl(hl_ns, hl_group.name, hl_group.definition)
-- end

local M = {}

-- Letters used for quick selection
local chars = "abcd" -- efghijklmnopqrstuvwxyz

local idx_to_chr = {}
for i = 1, #chars do
	idx_to_chr[i - 1] = chars:sub(i, i)
end


function M.select(items, opts, on_choice)
	if #items == 0 then
		print("No items to choose from.")
		return
	end
	opts = opts or {}
	opts.format_item = opts.format_item or tostring

	-- Window dimensions
	local height = math.min(#items, #chars)
	local width = 1 -- will be max line size

	-- Lists of items
	-- Items are separated in pages of max-size height
	local lists = {}
	local cur_list = {}

	for i, item in ipairs(items) do
		-- Start new list if current is full
		if #cur_list >= height then
			table.insert(lists, cur_list)
			cur_list = {}
		end

		local letter = idx_to_chr[(i - 1) % #chars]
		local line = string.format("%s %s", letter, opts.format_item(item))

		table.insert(cur_list, line)

		width = math.max(#line, width)
	end
	table.insert(lists, cur_list)

	-- Initiate window variable so buffer mappings refer to the window
	local win = -1

	-- Buffer table, one per list
	local bufs = {}

	for i, list in ipairs(lists) do
		local buf = vim.api.nvim_create_buf(false, true)
		table.insert(bufs, buf)

		-- Set buffer content
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)

		-- Set buffer options
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].modifiable = false
		vim.bo[buf].filetype = "ui-select"

		local map_opts = { nowait = true, buffer = buf }

		local function select(idx)
			vim.api.nvim_win_close(win, true)
			for _, buffer in ipairs(bufs) do
				vim.api.nvim_buf_delete(buffer, { force = true })
			end
			if idx then
				local item_idx = idx + 1 + (i - 1) * height
				on_choice(items[item_idx], item_idx)
			else
				on_choice(nil, nil)
			end
		end

		-- Escape to cancel
		vim.keymap.set("n", "<Esc>", function() select(nil) end, { nowait = true, buffer = buf })

		vim.keymap.set("n", "<CR>", function() select(vim.api.nvim_win_get_cursor(win)[1] - 1) end, map_opts)

		-- Line keymaps
		for idx = 0, #list - 1 do
			vim.keymap.set("n", idx_to_chr[idx], function() select(idx) end, map_opts)
		end

		-- Page change keymaps
		if i < #lists then
			vim.keymap.set("n", "l", function() vim.api.nvim_win_set_buf(win, bufs[i + 1]) end, map_opts)
		end

		if i > 1 then
			vim.keymap.set("n", "h", function() vim.api.nvim_win_set_buf(win, bufs[i - 1]) end, map_opts)
		end
	end

	-- Create window
	local win_opts = {
		relative = "cursor",
		row = 0,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = opts.prompt or "",
		title_pos = "center",
	}

	win = vim.api.nvim_open_win(bufs[1], true, win_opts)

	-- Set window options
	vim.wo[win].foldenable = false
	vim.wo[win].wrap = false
	vim.wo[win].cursorline = true
end

vim.ui.select = M.select
