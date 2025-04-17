vim.b.did_ftplugin = 1

vim.opt_local.wrap = true
vim.opt_local.comments = "s:<!--,mb: ,e:-->"
vim.opt_local.commentstring = "<!-- %s -->"

vim.keymap.set({ "o", "x" }, "il", function() require("various-textobjs").mdlink("inner") end, { buffer = 0 })
vim.keymap.set({ "o", "x" }, "al", function() require("various-textobjs").mdlink("outer") end, { buffer = 0 })
vim.keymap.set({ "o", "x" }, "ie", function() require("various-textobjs").mdEmphasis("inner") end, { buffer = 0 })
vim.keymap.set({ "o", "x" }, "ae", function() require("various-textobjs").mdEmphasis("outer") end, { buffer = 0 })
vim.keymap.set({ "o", "x" }, "ic", function() require("various-textobjs").mdFencedCodeBlock("inner") end, { buffer = 0 })
vim.keymap.set({ "o", "x" }, "ac", function() require("various-textobjs").mdFencedCodeBlock("outer") end, { buffer = 0 })

local OpenMarkdown = function()
  local peek = require("peek")
  if peek.is_open() then
    peek.close()
  else
    peek.open()
  end
end

vim.keymap.set("n", "<leader>m", OpenMarkdown, { buffer = 0, desc = "Open Markdown" })
