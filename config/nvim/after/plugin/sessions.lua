local sessions_folder = vim.fn.expand("~") .. "/Docs/.nvim/sessions"

-- Ensure sessions directory exists
vim.fn.mkdir(sessions_folder, "p")

-- Global variable to store current session info
vim.g.current_session = nil

-- Save current session
local function save_session()
	local session = vim.g.current_session

	if not session then
		math.randomseed(os.time())
		local session_id = tostring(math.random(10000000000, 99999999999))

		session = {
			name = vim.fn.input("Session name: "),
			path = string.format("%s/%s.vim", sessions_folder, session_id)
		}

		if session.name == "" then
			vim.notify("Session save cancelled", vim.log.levels.INFO)
			return
		end
	end

	-- Save the session
	vim.cmd("mksession! " .. vim.fn.fnameescape(session.path))

	-- Append buffer variables
	local file = io.open(session.path, "a")
	if file then
		for _, cmd in ipairs(BufferTimeRestoreStrings()) do
			file:write("\n" .. cmd)
		end
		-- Append the session name as a comment
		file:write('\n" session_name:' .. session.name)
		file:close()
	end

	-- Update global variable
	vim.g.current_session = session

	vim.notify("Session saved: " .. session.name, vim.log.levels.INFO)
end

-- Extract session name from file
local function get_session_name_from_file(file_path)
	local file = io.open(file_path, "r")
	if not file then return nil end

	local last_line = nil
	for line in file:lines() do
		last_line = line
	end

	file:close()

	-- Look for the session name in the last line
	return last_line:match('" session_name:([^\n]+)$')
end

-- List all available sessions
local function list_sessions()
	local sessions = {}
	local session_files = vim.fn.glob(sessions_folder .. "/*.vim", false, true)

	for _, file_path in ipairs(session_files) do
		local session_name = get_session_name_from_file(file_path)
		if session_name then
			table.insert(sessions, {
				name = session_name,
				path = file_path
			})
		end
	end

	if #sessions == 0 then
		vim.notify("No sessions found", vim.log.levels.INFO)
		return nil
	end

	return sessions
end

-- Delete a session
local function delete_session()
	local sessions = list_sessions()
	if not sessions then return end

	vim.ui.select(
		sessions,
		{
			prompt = "Delete session:",
			format_item = function(item) return item.name end,
		},
		function(session, _)
			if not session then return end

			-- Delete the file
			vim.fn.delete(session.path)

			if vim.g.current_session.path == session.path then
				vim.g.current_session = nil
			end
			vim.notify("Session deleted: " .. session.name, vim.log.levels.INFO)
		end
	)
end

-- Search and select a session
local function search_session()
	local sessions = list_sessions()
	if not sessions then return end

	vim.ui.select(
		sessions,
		{
			prompt = " Session ",
			format_item = function(item) return item.name end,
		},
		function(session, _)
			if not session then return end

			-- Close all buffers
			vim.cmd("silent! %bdelete!")

			-- Load the session
			vim.cmd("silent! source " .. vim.fn.fnameescape(session.path))

			-- Update global variable
			vim.g.current_session = session

			vim.notify("Session loaded: " .. session.name, vim.log.levels.INFO)
		end
	)
end

-- Create user commands
vim.api.nvim_create_user_command("SessionSave", save_session, {})

vim.api.nvim_create_user_command("SessionSearch", search_session, {})

vim.api.nvim_create_user_command("SessionDelete", delete_session, {})

-- Set up auto-save on exit
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
	group = vim.api.nvim_create_augroup("NvimSessions", { clear = true }),
	callback = function()
		if vim.g.current_session.path then
			save_session()
		end
	end,
})

vim.keymap.set("n", "<leader>sf", search_session, { desc = "Search", noremap = true })
vim.keymap.set("n", "<leader>sd", delete_session, { desc = "Delete", noremap = true })
vim.keymap.set("n", "<leader>ss", save_session, { desc = "Save", noremap = true })
