local function start_server()
  vim.system({ "python", "-m", "http.server", "8000", "--bind", "127.0.0.1" }, { cwd = vim.uv.cwd() })
  vim.notify("Server started on port 8000", vim.log.levels.INFO)
end

local function open_browser()
  vim.system({ "firefox", "-P", "Minimal", "127.0.0.1:8000" }, { detach = true })
end

vim.keymap.set(
  "n", "<leader>m", start_server,
  {
    buffer = 0,
    desc = "Open Server",
  }
)

vim.keymap.set(
  "n", "<S-CR>", open_browser,
  {
    buffer = 0,
    desc = "Open Browser",
  }
)
