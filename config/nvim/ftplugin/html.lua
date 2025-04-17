vim.keymap.set(
  "n", "<leader>m",
  function()
    vim.system({ "python", "-m", "http.server", "8000", "--bind", "0.0.0.0" }, { cwd = vim.uv.cwd() })
    vim.system({ "firefox", "-P", "Minimal", "0.0.0.0:8000" })
  end,
  {
    buffer = 0,
    desc = "Open Server",
  }
)
