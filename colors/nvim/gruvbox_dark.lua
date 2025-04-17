
require("gruvbox").setup({
  contrast = "",
  transparent_mode = true,
  overrides = {
    SnippetTabstop = {},
    TreesitterContext = { link = "CursorLine" },
  }
})

vim.opt.background = "dark"
vim.cmd("colorscheme gruvbox")

