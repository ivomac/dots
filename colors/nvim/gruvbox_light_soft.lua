
require("gruvbox").setup({
  contrast = "soft",
  transparent_mode = true,
  overrides = {
    CursorLine = { bg_indexed = true, ctermbg = 0 },
    SnippetTabstop = {},
    TreesitterContext = { link = "CursorLine" },
  }
})

vim.opt.background = "light"
vim.cmd("colorscheme gruvbox")

