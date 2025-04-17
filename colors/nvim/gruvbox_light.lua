
require("gruvbox").setup({
  contrast = "",
  transparent_mode = true,
  overrides = {
    SnippetTabstop = {},
    TreesitterContext = { link = "CursorLine" },
  }
})

vim.opt.background = "light"
vim.cmd("colorscheme gruvbox")

