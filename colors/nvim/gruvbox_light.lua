vim.api.nvim_set_hl(0, "CursorLine", {})
vim.api.nvim_set_hl(0, "TreesitterContext", {})

require("gruvbox").setup({
  contrast = "",
  transparent_mode = true,
})

vim.opt.background = "light"
vim.cmd("colorscheme gruvbox")

vim.api.nvim_set_hl(0, "SnippetTabstop", {})
vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
