
vim.opt_local.makeprg = "latexmk -interaction=nonstopmode %"

vim.opt_local.wrap = true

vim.api.nvim_create_user_command("View",
	function()
		local path = vim.fn.expand("%:p")
		local pdf = string.gsub(path, ".tex", ".pdf")
		local server = vim.v.servername
		local linenum = vim.fn.line(".")
		local remote_send = ""
		local cmd = "silent !zathura " .. vim.fn.shellescape(path:gsub("%.typ$", ".pdf")) .. " &"
		vim.cmd(cmd)
	end,
	{ }
)

vim.keymap.set("n", "<C-h>", function() vim.cmd("View") end, { desc = "View PDF" } )

vim.api.nvim_create_autocmd({"VimLeavePre"}, {
	buffer = 0,
	callback = function()
		vim.cmd("!cleantex")
	end,
})

