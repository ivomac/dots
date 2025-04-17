HOME = os.getenv("HOME")

vim.opt.wrap = false

vim.opt.path:append("**")
vim.opt.nrformats = { "bin", "hex", "alpha" }
vim.opt.ttimeoutlen = 9999
vim.opt.timeout = true
vim.opt.timeoutlen = 9999
vim.opt.virtualedit = "block"

vim.opt.showmode = false
vim.opt.showcmd = false

vim.opt.viewoptions = { "cursor", "folds", "slash", "unix" }

vim.opt.cpoptions = "aBcFn_"
vim.opt.completeopt = "menu,noselect"

vim.opt.sessionoptions="buffers,curdir,help,tabpages,winsize,winpos,terminal"

vim.opt.commentstring = "# %s"

vim.opt.wildignore:append({ ".git", ".gitignore" })
vim.opt.matchpairs:append("<:>")
vim.opt.swapfile = false

vim.opt.updatetime = 500

vim.opt.undolevels = 1000
vim.opt.undofile = true
vim.opt.foldenable = false
vim.opt.foldcolumn = "0"
vim.opt.signcolumn = "no"
vim.opt.shortmess = "taoOWTF"
vim.opt.showtabline = 1
vim.opt.laststatus = 3
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.breakindent = true
vim.opt.sidescroll = 8
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showbreak = "…"
vim.opt.list = true
vim.opt.listchars = { tab = "│ ", trail = "·", extends = "»", precedes = "«", nbsp = "•", eol = "¬" }
vim.opt.fillchars = { stl = " ", stlnc = " ", fold = " ", vert = "│", eob = "~" }
vim.opt.linebreak = true
vim.opt.autoindent = false
vim.opt.indentkeys = { "o", "O" }
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.cursorline = true
vim.opt.formatoptions = "j"

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter", "BufEnter" }, {
	pattern = { "*" },
	callback = function()
		vim.opt_local.cursorline = true
		vim.opt_local.formatoptions = "j"
	end
})

local cursor_group = vim.api.nvim_create_augroup("ReturnToLastPosition", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = cursor_group,
	pattern = "*",
	callback = function()
		local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, { row, col })
		end
	end
})

local highlight_group = vim.api.nvim_create_augroup("HighlightYank", { clear = true })
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    group = highlight_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ highlight = "IncSearch", timeout = 120 })
	end,
})

if vim.g.started_by_firenvim then
	vim.opt.laststatus = 0
end
