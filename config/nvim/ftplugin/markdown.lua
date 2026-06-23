vim.b.did_ftplugin = 1

vim.opt_local.wrap = true
vim.opt_local.comments = "s:<!--,mb: ,e:-->"
vim.opt_local.commentstring = "<!-- %s -->"

local OpenMarkdown = function()
  local rm = require("render-markdown")
  rm.toggle()
end

vim.keymap.set("n", "<leader>m", OpenMarkdown, { buffer = 0, desc = "Open Markdown" })
