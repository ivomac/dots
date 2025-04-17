HOME = os.getenv("HOME")

vim.opt.wrap = false

vim.opt.path:append("**")
vim.opt.nrformats = { "bin", "hex", "alpha" }
vim.opt.ttimeoutlen = 9999
vim.opt.timeout = true
vim.opt.timeoutlen = 9999
vim.opt.virtualedit = "block"

vim.opt.winborder = "rounded"

vim.opt.showmode = false
vim.opt.showcmd = false

vim.opt.viewoptions = { "cursor", "folds", "slash", "unix" }

vim.opt.cpoptions = "aBcFn_"
vim.opt.completeopt = { "menu", "noselect" }

vim.opt.sessionoptions = {
  "buffers",
  "curdir"
}

vim.opt.comments = ""
vim.opt.commentstring = ""

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

vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.cursorline = true
vim.opt.formatoptions = "j"

vim.highlight.priorities = {
  syntax = 50,
  semantic_tokens = 100,
  treesitter = 150,
  diagnostics = 200,
  user = 250
}

if vim.g.started_by_firenvim then
  vim.opt.laststatus = 0
end
