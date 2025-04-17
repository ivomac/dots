BROWSER = "firefox"
GOOGLE_NCR_SEARCH = "https://www.google.com/search?q=%s&pws=0&gl=us&gws_rd=cr"

local function open_in_browser(url)
	if url:sub(1, 4) ~= "http" then
		url = string.format(GOOGLE_NCR_SEARCH, url)
	end
	local cmd = { BROWSER, url }
	vim.fn.jobstart(cmd, { detach = true })
end

local get_visual_selection = function()
	vim.fn.feedkeys(":", "nx")
	local mode = vim.fn.visualmode()
	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	local lines = vim.fn.getregion(vstart, vend, { type = mode })
	return vim.fn.join(lines, "  ")
end

vim.keymap.set("n", "<CR>",
	function()
		if vim.bo.buftype == "quickfix" then
			local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
			vim.api.nvim_feedkeys(enter, "nt", false)
		else
			local text = vim.fn.expand("<cfile>")
			open_in_browser(text)
		end
	end,
	{ silent = true, desc = "Open links" }
)

vim.keymap.set("x", "<CR>",
	function()
		local text = get_visual_selection()
		open_in_browser(text)
	end,
	{ silent = true, desc = "Open links" }
)

function ViewPdf()
	local buffer_path = vim.fn.expand("%:p")
	local pdf_path = buffer_path:gsub("%.[^%.]+$", ".pdf")

	if vim.fn.filereadable(pdf_path) == 0 then
		print("Pdf file not found.")
		return
	end

	local cmd_template = 'silent !zathura %s &'
	local cmd = string.format(cmd_template, pdf_path)

	vim.cmd(cmd)
end

vim.api.nvim_create_user_command("ViewPdf", ViewPdf, {})

vim.keymap.set("n", "<leader>v", ViewPdf, { desc = "View PDF" })
