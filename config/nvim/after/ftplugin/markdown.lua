vim.opt_local.makeprg = nil

vim.opt_local.wrap = true
vim.opt_local.conceallevel = 0

vim.keymap.set({ "o", "x" }, "il", function() require("various-textobjs").mdlink("inner") end, { buffer = true })
vim.keymap.set({ "o", "x" }, "al", function() require("various-textobjs").mdlink("outer") end, { buffer = true })
vim.keymap.set({ "o", "x" }, "ie", function() require("various-textobjs").mdEmphasis("inner") end, { buffer = true })
vim.keymap.set({ "o", "x" }, "ae", function() require("various-textobjs").mdEmphasis("outer") end, { buffer = true })
vim.keymap.set({ "o", "x" }, "ic", function() require("various-textobjs").mdFencedCodeBlock("inner") end, { buffer = true })
vim.keymap.set({ "o", "x" }, "ac", function() require("various-textobjs").mdFencedCodeBlock("outer") end, { buffer = true })

local OpenMarkdown = function()
	local peek = require("peek")
	if peek.is_open() then
		peek.close()
	else
		peek.open()
	end
end

vim.keymap.set("n", "<leader>M", OpenMarkdown, { desc = "Open Markdown" })
