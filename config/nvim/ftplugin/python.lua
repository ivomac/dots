vim.b.did_ftplugin = 1

vim.opt_local.commentstring = "# %s"
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

local ipy_term

function IPythonToggle()
  if not ipy_term then
    ipy_term = require("toggleterm.terminal").Terminal:new({
      cmd = "ipython",
      direction = "vertical"
    })
  end
  ipy_term:toggle()
end

vim.api.nvim_buf_create_user_command(0, "IPythonToggle", IPythonToggle, {})

vim.keymap.set({ "t", "n" }, "<C-l>", IPythonToggle, { desc = "Toggle Term" })
