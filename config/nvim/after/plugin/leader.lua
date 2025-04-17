local suffix = "egi<Left><Left><Left><Left>"

vim.keymap.set("n", "<leader>ar", ":'{,'}s:\\V\\<<c-r><c-w>\\>::" .. suffix, { desc = "Replace word in par" })
vim.keymap.set("n", "<leader>aR", ":%s:\\V\\<<c-r><c-w>\\>::" .. suffix, { desc = "Replace word in file" })

vim.keymap.set("x", "<leader>ar", "y:'{,'}s:\\V<c-r>\"::" .. suffix, { desc = "Replace sel. in par" })
vim.keymap.set("x", "<leader>aR", "y:%s:\\V<c-r>\"::" .. suffix, { desc = "Replace sel. in file" })

vim.keymap.set("n", "<leader>aw", ":%s:\\s\\+$::<CR>", { desc = "Remove trailing ␣" })
vim.keymap.set("x", "<leader>aw", ":s:\\s\\+$::<CR>", { desc = "Remove trailing ␣" })

vim.keymap.set("n", '<leader>a"', 'mz:%v:": s:\':":egi<CR>`zzz', { desc = "Quote to DQuote" })
vim.keymap.set("n", "<leader>a'", "mz:%v:': s:\":':egi<CR>`zzz", { desc = "DQuote to Quote" })

vim.keymap.set("n", "<leader>a<Tab>", ":setlocal noexpandtab<CR>:retab!<CR>", { desc = "Spaces to Tabs" })
vim.keymap.set("n", "<leader>a ", ":setlocal expandtab<CR>:retab!<CR>", { desc = "Tabs to Spaces" })

function ReadableGitFiles()
	local git_files = vim.fn.systemlist("git ls-files --full-name")
	local readable_files = {}

	for i, file in ipairs(git_files) do
		if vim.fn.filereadable(file) then
			readable_files[i] = vim.fn.fnameescape(vim.fn.fnamemodify(file, ":p"))
		end
	end
	return readable_files
end

local function edit_git_files()
	for _, file in ipairs(ReadableGitFiles()) do
		vim.cmd("silent badd " .. file)
	end
end

vim.api.nvim_create_user_command("To",
	function(opts)
		local dest = opts.fargs[1]
		local dest_path = ""
		if dest == "parent" then
			dest_path = ".."
		elseif dest == "current" then
			dest_path = vim.fn.expand("%:p:h")
		elseif dest == "git" then
			local dot_git_path = vim.fn.finddir(".git", ".;")
			dest_path = vim.fs.dirname(dot_git_path)
		end
		if dest_path == nil or dest_path == "" or dest_path == "." then
			return
		end
		vim.cmd("cd!" .. dest_path)
	end,
	{ nargs = 1 }
)

vim.api.nvim_create_augroup("GitCd", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	group = "GitCd",
	callback = function(args)
		local buftype = vim.bo[args.buf].buftype
		local filetype = vim.bo[args.buf].filetype

		if buftype ~= "" or filetype == "help" or filetype == "man" then
			return
		end
		vim.cmd("To git")
	end
})


vim.api.nvim_create_user_command("EditGitFiles", edit_git_files, { nargs = 0 })

vim.keymap.set("n", "<leader>c%", function() vim.cmd.To("current") end, { desc = "cd %" })
vim.keymap.set("n", "<leader>c.", function() vim.cmd.To("parent") end, { desc = "cd .." })
vim.keymap.set("n", "<leader>cg", function() vim.cmd.To("git") end, { desc = "cd git root" })
vim.keymap.set("n", "<leader>ce", edit_git_files, { desc = "Edit all Git files" })

vim.api.nvim_create_user_command("Rename",
	function(opts)
		local name = vim.fn.expand("%:p")
		local folder = vim.fn.expand("%:p:h")
		local new_name = folder .. "/" .. opts.fargs[1]
		os.rename(name, new_name)
		vim.cmd("e " .. new_name)
		vim.cmd("bd #")
		print("mv -> " .. new_name)
	end,
	{ nargs = 1 }
)

vim.api.nvim_create_user_command("Remove",
	function()
		os.remove(vim.fn.expand("%:p"))
		vim.cmd("bd")
		print("rm %")
	end,
	{ nargs = 0 }
)

vim.api.nvim_create_user_command("Chmod",
	function(opts)
		local file = vim.api.nvim_buf_get_name(0)
		vim.cmd("silent !chmod " .. opts.fargs[1] .. " " .. file)
	end,
	{ nargs = 1 }
)


vim.api.nvim_create_autocmd({ "Filetype" }, {
	group = vim.api.nvim_create_augroup("AutoExecutable", { clear = true }),
	pattern = {"sh", "zsh", "bash"},
	callback = function()
		vim.cmd("Chmod +x")
	end,
})

vim.keymap.set("n", "<leader>M", function() vim.cmd("make") end, { desc = "Make" })
