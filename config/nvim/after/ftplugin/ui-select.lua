local guicursor = vim.opt.guicursor

vim.api.nvim_set_hl(0, "HiddenCursor", { reverse = true, blend = 100 })

vim.opt.guicursor = 'a:HiddenCursor/lCursor'

vim.api.nvim_create_autocmd("BufLeave", {
	group = vim.api.nvim_create_augroup("AU_GUICURSOR", { clear = true }),
	buffer = 0,
	callback = function()
		vim.opt.guicursor = guicursor
	end,
})

