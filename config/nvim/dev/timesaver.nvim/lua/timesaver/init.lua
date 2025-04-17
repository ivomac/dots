local M = {}


--- Set buffer time
function M.set_time(bufname, time)
  local bufnr = vim.fn.bufnr(bufname)
  if bufnr ~= -1 then
    vim.api.nvim_buf_set_var(bufnr, "focus_time", time)
  end
end

--- Reset buffer times
function M.reset_times()
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    vim.api.nvim_buf_set_var(buf.bufnr, "focus_time", nil)
  end
  vim.api.nvim_set_var("last_time", vim.uv.hrtime())
end

--- Update buffer time
function M.update_time(bufnr)
  local diff = vim.uv.hrtime() - vim.g.last_time
  local focus_time = vim.b[bufnr].focus_time or 0

  vim.api.nvim_buf_set_var(bufnr, "focus_time", focus_time + diff)

  vim.api.nvim_set_var("last_time", vim.uv.hrtime())
end

function M.setup()
  vim.api.nvim_set_var("last_time", vim.uv.hrtime())

  local augroup = vim.api.nvim_create_augroup("SAVE_TIME", { clear = true })

  vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained" },
    {
      group = augroup,
      callback = function()
        vim.api.nvim_set_var("last_time", vim.uv.hrtime())
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "SessionWritePost" },
    {
      group = augroup,
      callback = function(ev)
        M.update_time(ev.buf)
      end,
    }
  )
end

return M
