PDF = "zathura"

vim.opt_local.makeprg = "cd %:p:h && latexmk -interaction=nonstopmode -pvc %:p &"
vim.opt_local.wrap = true

vim.api.nvim_create_autocmd({"VimLeavePre"}, {
	buffer = 0,
	callback = function()
		vim.cmd("!cd %:p:h && latexmk -c")
	end,
})


function ViewPdf()
	local buffer_path = vim.fn.expand("%:p")
	local pdf_path = buffer_path:gsub("%.[^%.]+$", ".pdf")

	if vim.fn.filereadable(pdf_path) == 0 then
		print("Pdf file not found.")
        return
    end

	local server = vim.v.servername
	local sync_cmd =  "nvim --server " .. server .. " --remote-send '<cmd>%{line}<CR><cmd>e %{input}<CR>'"

	local cmd = { PDF, "--synctex-editor-command", sync_cmd, pdf_path }
	vim.fn.jobstart(cmd, { detach = true })
end

function GoToLineInPdf()
	local buffer_path = vim.fn.expand("%:p")
	local pdf_path = buffer_path:gsub("%.[^%.]+$", ".pdf")

	if vim.fn.filereadable(pdf_path) == 0 then
		print("Pdf file not found.")
        return
    end

	local pos = vim.fn.getpos(".")

	local sync_fwd = string.format("%s:%s:%s", pos[2], pos[3], buffer_path)

	local cmd = { PDF, "--synctex-forward", sync_fwd, pdf_path }
	vim.fn.jobstart(cmd, { detach = true })
end

vim.api.nvim_buf_create_user_command(0, "ViewPdf", ViewPdf, {})
vim.api.nvim_buf_create_user_command(0, "GoToLineInPdf", GoToLineInPdf, {})

vim.keymap.set("n", "<leader>v", ViewPdf, { buffer = 0, desc = "View PDF" } )
vim.keymap.set("n", "<C-CR>", GoToLineInPdf, { buffer = 0, desc = "Go to line in PDF" } )

