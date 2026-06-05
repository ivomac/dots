local server_handle = nil

local function toggle_server()
  if server_handle and not server_handle:is_closing() then
    server_handle:kill(2)
    vim.notify("Stopping HTTP server...", vim.log.levels.INFO)
  else
    server_handle = vim.system(
      { "python", "-m", "http.server", "8000", "--bind", "127.0.0.1" },
      { cwd = vim.fn.getcwd() },
      function()
        server_handle = nil
        vim.schedule(function()
          vim.notify("HTTP server stopped", vim.log.levels.INFO)
        end)
      end
    )
    vim.notify("HTTP server started on http://127.0.0.1:8000", vim.log.levels.INFO)
    vim.system({ "firefox", "-P", "Minimal", "127.0.0.1:8000" }, { detach = true })
  end
end

vim.keymap.set("n", "<leader>m", toggle_server, { buffer = 0, desc = "Toggle HTTP server" })
