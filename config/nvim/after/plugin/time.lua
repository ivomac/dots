--[[
* Author: Ivo Maceira <ivomaceira@gmail.com>
* License: MIT
*
* Description:
*   Buffer time tracking and switching plugin for Neovim.
*   Tracks time spent in each buffer during a session and
*   across sessions. Provides commands to switch between
*   buffers based on time spent.
]]


--- @type integer
local AU_CHRONOBUF = vim.api.nvim_create_augroup("chronobuf", { clear = true })

--- @type integer
local LAST_TIME = os.time()


--- Get buffer info (if it's a nice buffer)
--- @param buf integer|string
--- @return table|nil
function GetBufferInfo(buf)
	local bufname, bufnr

	if type(buf) == "string" then
		bufname = buf
		bufnr = vim.fn.bufnr(bufname)
	else
		bufnr = buf
		bufname = vim.api.nvim_buf_get_name(bufnr)
	end

	if
		bufnr ~= -1
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.fn.filereadable(bufname) == 1
	then
		local relative_parent = vim.fn.fnamemodify(bufname, ":~:.:h")
		local short_relative_parent = vim.fn.pathshorten(relative_parent, 4)

		return {
			number = bufnr,
			name = bufname,
			file_name = vim.fn.fnamemodify(bufname, ":t"),
			short_relative_parent = short_relative_parent,
			time = vim.b[bufnr].focus_time or 0,
		}
	end

	return nil
end

--- Set buffer time
--- @param bufname string
--- @param time integer
--- @return nil
function SetBufferTime(bufname, time)
	local buf_info = GetBufferInfo(bufname)
	if buf_info then
		vim.b[buf_info.number].focus_time = time
	end
end

--- Update buffer time
--- @param bufnr integer
--- @return nil
function UpdateBufferTime(bufnr)
	local current_time = os.time()
	local diff = current_time - LAST_TIME

	vim.b[bufnr].focus_time = (vim.b[bufnr].focus_time or 0) + diff

	LAST_TIME = current_time
end

vim.api.nvim_create_autocmd(
	{ "BufEnter", "FocusGained" }, -- , "VimEnter"
	{
		group = AU_CHRONOBUF,
		callback = function()
			LAST_TIME = os.time()
		end,
	}
)

vim.api.nvim_create_autocmd(
	{ "BufLeave", "FocusLost" }, -- , "VimLeavePre"
	{
		group = AU_CHRONOBUF,
		callback = function(ev)
			UpdateBufferTime(ev.buf)
		end,
	}
)

--- @param time integer
--- @return string
local function format_time(time)
	local seconds = time % 60
	local minutes = math.floor((time % 3600) / 60)
	local hours = math.floor(time / 3600)
	if hours == 0 and minutes == 0 then
		return string.format("%ds", seconds)
	elseif hours == 0 then
		return string.format("%dm", minutes)
	else
		return string.format("%dh%02d", hours, minutes)
	end
end

--- Create a table of buffer info
--- @param keep boolean|nil  keep current
--- @return table bufs
function GetTimeTable(keep)
	if keep then
		UpdateBufferTime(0)
	end

	local cur_bufnr = vim.api.nvim_get_current_buf()

	local bufs = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if keep or bufnr ~= cur_bufnr then
			local buf = GetBufferInfo(bufnr)
			if buf and buf.time > 0 then
				table.insert(bufs, buf)
			end
		end
	end

	return bufs
end

function BufferTimeRestoreStrings()
	local buftime_template = 'lua SetBufferTime("%s", %d)'
	local buftime_cmds = {}
	for _, buf in ipairs(GetTimeTable(true)) do
		local restore_cmd = string.format(buftime_template, buf.name, buf.time)
		table.insert(buftime_cmds, restore_cmd)
	end
	return buftime_cmds
end


local function get_max_sizes(tbl)
	local maxl = {}
	for _, item in ipairs(tbl) do
		for key, value in pairs(item) do
			if type(value) == "string" then
				value = #value
			end
			if (maxl[key] or 0) <= value then
				maxl[key] = value
			end
		end
	end
	return maxl
end

local function ljustify(str, len)
	return str .. string.rep(" ", (len or 0) - #str)
end

local function rjustify(str, len)
	return string.rep(" ", (len or 0) - #str) .. str
end

local function change_buffer()
	local info_table = GetTimeTable()

	if #info_table == 0 then
		print("No other buffers loaded.")
		return
	end

	table.sort(info_table, function(a, b) return a.time > b.time end)

	local maxl = get_max_sizes(info_table)
	local max_time = format_time(maxl.time)

	vim.ui.select(
		info_table,
		{
			format_item = function(buf)
				local file_name = buf.file_name
				local short_rel_parent = string.format("(%s)", buf.short_relative_parent)
				local time = format_time(buf.time)

				return string.format(
					"%s %s %s",
					ljustify(file_name, maxl.file_name),
					ljustify(short_rel_parent, maxl.short_relative_parent + 2),
					rjustify(time, #max_time)
				)
			end,
		},
		function(buf, _)
			if buf then
				vim.api.nvim_set_current_buf(buf.number)
			end
		end
	)
end

--- Command to select and focus a buffer based on time spent
vim.api.nvim_create_user_command("BS", change_buffer, {})

--- DEBUG
vim.api.nvim_create_user_command("BSDEBUG",
	function()
		print("CURRENT_TIME:", os.time())
		print("LAST_TIME:", LAST_TIME)
		print("SESSION_BUF_INFO:")
		for bufname, info in pairs(BUFFER_INFO) do
			print("bufname:", bufname)
			for key, val in pairs(info) do
				print(key, val)
			end
		end
	end,
	{}
)

-- vim.keymap.set("n", "m", change_buffer, { silent = true, noremap = true, desc = "Change Buffer" })
