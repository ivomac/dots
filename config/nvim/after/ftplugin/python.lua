
local ipython = require("toggleterm.terminal").Terminal:new({
		cmd = "ipython",
		direction = "vertical"
	})

function IpythonToggle()
	ipython:toggle()
end

vim.api.nvim_buf_create_user_command(0, "IpythonToggle", IpythonToggle, {})

vim.keymap.set({"t", "n"}, "<C-l>", "<cmd>IpythonToggle<CR>", {desc="Toggle Term"})

