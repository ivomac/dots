vim.api.nvim_create_user_command('SW',
	function()
		vim.cmd("silent! w !sudo -A tee % > /dev/null")
		vim.cmd("edit!")
	end,
	{ bang = true }
)

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	group = vim.api.nvim_create_augroup("WriteOnEsc", { clear = true }),
	pattern = "*",
	callback = function()
		-- save with <Esc> in normal mode (if not read-only)
		if vim.g.started_by_firenvim then
			vim.keymap.set({ "i", "v" }, "<Esc>", "<Esc>:silent write<CR>", { noremap = true, silent = true })
			vim.keymap.set({ "n" }, "<Esc>", "<Esc>:silent write<CR>:quit<CR>", { noremap = true, silent = true })
		elseif not vim.bo.readonly and not vim.b[0].was_readonly then
			vim.keymap.set("n", "<Esc>",
				function()
					if vim.bo.modified and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
						return vim.cmd("write")
					end

					if
						not vim.bo.modified
						and vim.fn.bufname('%') == ''
						and vim.fn.line('$') == 1
						and vim.fn.getline(1) == ""
						and #vim.fn.getbufinfo({ buflisted = 1 }) == 1
					then
						return vim.cmd('silent quit')
					end
				end,
				{ noremap = true, silent = true }
			)
		else
			vim.opt_local.readonly = false
			vim.opt_local.autoread = true
			vim.b[0].was_readonly = true
		end
	end,
})
