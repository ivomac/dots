
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.jsonc",
	callback = function() vim.bo.filetype = 'jsonc' end,
})

