local M = {}


function M.setup()
  local augroup = vim.api.nvim_create_augroup("TIMESAVER", { clear = true })

  vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    {
      group = augroup,
      callback = function(ev)
        local now = vim.uv.hrtime()
        vim.api.nvim_buf_set_var(ev.buf, "TS_twrite", now)

        local nwrite = vim.b[ev.buf].TS_nwrite or 0
        vim.api.nvim_buf_set_var(ev.buf, "TS_nwrite", nwrite + 1)
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained" },
    {
      group = augroup,
      callback = function(ev)
        local now = vim.uv.hrtime()
        vim.api.nvim_buf_set_var(ev.buf, "ts_tfocus", now)

        local naccess = vim.b[ev.buf].TS_nfocus or 0
        vim.api.nvim_buf_set_var(ev.buf, "TS_nfocus", naccess + 1)
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "SessionWritePost" },
    {
      group = augroup,
      callback = function(ev)
        local now = vim.uv.hrtime()
        local diff = now - (vim.b[ev.buf].ts_tfocus or now)
        local tfocus = vim.b[ev.buf].TS_tfocused or 0

        vim.api.nvim_buf_set_var(ev.buf, "TS_tfocused", tfocus + diff)
        vim.api.nvim_buf_set_var(ev.buf, "ts_tfocus", now)
      end,
    }
  )
end

return M
