
local group = vim.api.nvim_create_augroup("LARGE_FILES", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
	pattern = "*",
	callback = function(ev)
		local max_filesize = 1 * 1024 * 1024 -- 1 MB
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		if ok and stats and stats.size > max_filesize then
			vim.opt_local.syntax = "off"
			vim.opt_local.foldmethod = "manual"
		end

	end
})

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    group = group,
	pattern = "*",
	callback = function(ev)
		local max_filesize = 4 * 1024 * 1024 -- 4 MB
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		local input = "y"
		if ok and stats and stats.size > max_filesize then
			-- get user input to decide whether to open the file
			input = vim.fn.input("File is larger than 4 MB. Open anyway? [y/N]: ")
		end
		if input:lower() ~= "y" then
			vim.cmd("q!")
		end
	end
})

