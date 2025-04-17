vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		vim.cmd("startinsert")
	end,
	pattern = { "term://*" },
	group = vim.api.nvim_create_augroup("TermGroup", { clear = true }),
})

local terms = {}

local toggleterm = require("toggleterm.terminal")

local function NewFloatTerm(opts)
	local config = {
		direction = "float",
		on_create = function(term)
			local function close()
				if vim.fn.mode() == "t" then
					term:close()
				end
			end
			vim.keymap.set({ "n", "t" }, "<C-l>", close,
				{ buffer = term.bufnr, noremap = true, silent = true, desc = "Close terminal" })
			vim.api.nvim_buf_create_user_command(term.bufnr, "Close", close, {})
		end,
	}
	local merge = vim.tbl_deep_extend("force", config, opts or {})
	return toggleterm.Terminal:new(merge)
end

-- Shell

function ShellTerm()
	if terms["term"] == nil then
		terms["term"] = NewFloatTerm()
		local id = terms["term"].id
		vim.keymap.set("x", "<C-j><C-j>",
			function()
				require("toggleterm").send_lines_to_terminal("visual_lines", false, { args = id })
			end,
			{ noremap = true, silent = true, desc = "Send visual lines to terminal" }
		)
	end
	terms["term"]:toggle()
end

vim.keymap.set("n", "<leader>tt", ShellTerm, { noremap = true, silent = true, desc = "Toggle Term" })

-- Script

function RunScript()
	vim.cmd("Chmod +x", ".")
	local bufname = vim.api.nvim_buf_get_name(0)
	NewFloatTerm({ cmd = bufname, close_on_exit = false }):open()
end

vim.keymap.set("n", "<leader>tr", RunScript, { desc = "Run current script" })


-- Yazi

function Yazi(file)
	local cmd = "yazi " .. (file or vim.api.nvim_buf_get_name(0) or vim.fn.getcwd())
	terms["yazi"] = NewFloatTerm({
		cmd = cmd,
		on_create = function(term)
			local function shutdown()
				if vim.fn.mode() == "t" then
					term:shutdown()
				end
			end
			vim.keymap.set({ "n", "t" }, "<C-l>", shutdown,
				{ buffer = term.bufnr, noremap = true, silent = true, desc = "Close terminal" })
			vim.api.nvim_buf_create_user_command(term.bufnr, "Close", shutdown, {})
		end,
	})
	terms["yazi"]:toggle()
end

vim.api.nvim_create_user_command("Yazi", function() Yazi(nil) end, {})

vim.keymap.set("n", "<leader>te", Yazi, { noremap = true, silent = true, desc = "File explorer" })

vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd" }, {
	group = vim.api.nvim_create_augroup("Yazi", { clear = true }),
	pattern = "*",
	callback = function(ev)
		if vim.g.SessionLoad ~= 1 and vim.fn.isdirectory(ev.file) == 1 then
			vim.api.nvim_buf_delete(ev.buf, { force = true })
			Yazi(ev.file)
		end
	end
})

-- LazyGit

function LazyGit()
	if terms["lazygit"] == nil then
		terms["lazygit"] = NewFloatTerm({ cmd = "lazygit", dir = "git_dir" })
	end
	terms["lazygit"]:toggle()
end

function LazyGitLog()
	if terms["lazygitlog"] == nil then
		terms["lazygitlog"] = NewFloatTerm({ cmd = "lazygit log", dir = "git_dir" })
	end
	terms["lazygitlog"]:toggle()
end

function LazyGitFilter()
	if terms["lazygitfilter"] ~= nil then
		terms["lazygitfilter"]:shutdown()
		terms["lazygitfilter"] = nil
	end
	local cmd = "lazygit --filter " .. vim.api.nvim_buf_get_name(0)
	terms["lazygitfilter"] = NewFloatTerm({ cmd = cmd, dir = "git_dir" })
	terms["lazygitfilter"]:toggle()
end

vim.api.nvim_create_user_command("LazyGit", LazyGit, {})
vim.api.nvim_create_user_command("LazyGitLog", LazyGitLog, {})
vim.api.nvim_create_user_command("LazyGitFilter", LazyGitFilter, {})

vim.keymap.set("n", "<leader>tlg", LazyGit, { noremap = true, silent = true, desc = "LazyGit" })
vim.keymap.set("n", "<leader>tll", LazyGitLog, { noremap = true, silent = true, desc = "LazyGitLog" })
vim.keymap.set("n", "<leader>tlf", LazyGitFilter, { noremap = true, silent = true, desc = "LazyGitFilter" })


-- Aider

function Aider()
	if terms["aider"] == nil then
		terms["aider"] = NewFloatTerm({ cmd = "aid", dir = "git_dir" })
	end
	terms["aider"]:toggle()
end

vim.api.nvim_create_user_command("Aider", Aider, {})

vim.keymap.set("n", "<leader>ta", Aider, { noremap = true, silent = true, desc = "Aider" })
