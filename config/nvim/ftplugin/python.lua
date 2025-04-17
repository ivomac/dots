vim.b.did_ftplugin = 1

vim.opt_local.indentkeys = { 'o', 'O' }
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4

vim.g.python_indent = {
  disable_parentheses_indenting = false,
  closed_paren_align_last_line = false,
  searchpair_timeout = 150,
  continue = 'shiftwidth()',
  open_paren = 'shiftwidth()',
  nested_paren = 'shiftwidth()'
}
