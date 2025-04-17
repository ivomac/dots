local M = { queue = {}, log = {}, next = 1 }

function M.refresh_now()
  local width = M.opts.winconfig.title and #M.opts.winconfig.title or 1
  local height = 0

  local maxwidth = math.min(
    M.opts.max.width.absolute,
    math.ceil(M.opts.max.width.relative * (vim.o.columns - 2))
  )
  local maxheight = math.min(
    M.opts.max.height.absolute,
    math.ceil(M.opts.max.height.relative * (vim.o.lines - vim.o.cmdheight - 4))
  )

  local buflines, highlights = {}, {}
  for _, notification in pairs(M.queue) do
    for _, line in ipairs(notification.lines) do
      table.insert(buflines, line)

      height = height + math.ceil((#line + 1) / maxwidth)
      width = math.max(width, #line)
    end

    table.insert(
      highlights,
      {
        group = notification.hl,
        start = #buflines - #notification.lines,
        finish = #buflines,
      }
    )
  end

  if #buflines == 0 then
    if M.win then
      vim.api.nvim_win_close(M.win, true)
    end
    M.win = nil
    M.buf = nil
    M.refresh_scheduled = false
    return
  end

  if not M.buf then
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[M.buf].bufhidden = "wipe"
    vim.bo[M.buf].filetype = "ui-notify"
  else
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, true, {})
  end
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, true, buflines)

  -- Highlights
  local ns = vim.api.nvim_create_namespace("NOTIFY_HL")
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.hl.range(M.buf, ns, hl.group, { hl.start, 0 }, { hl.finish, -1 })
  end

  -- Window
  local winconfig = M.opts.winconfig
  winconfig.width = math.min(width, maxwidth)
  winconfig.height = math.min(height, maxheight)

  if not M.win then
    M.win = vim.api.nvim_open_win(M.buf, false, winconfig)
    vim.wo[M.win].foldenable = false
    vim.wo[M.win].foldmethod = "manual"
    vim.wo[M.win].wrap = true
    vim.wo[M.win].linebreak = false
  else
    vim.api.nvim_win_set_config(M.win, { width = winconfig.width, height = winconfig.height })
  end

  vim.cmd("redraw")

  M.refresh_scheduled = false
end

function M.refresh()
  if not M.refresh_scheduled then
    M.refresh_scheduled = true
    vim.schedule(M.refresh_now)
  end
end

function M.setup(opts)
  local default_opts = {
    levels = {
      ERROR = { duration = 5000, hl = "DiagnosticError" },
      WARN  = { duration = 5000, hl = "DiagnosticWarn" },
      INFO  = { duration = 4000, hl = "DiagnosticInfo" },
      DEBUG = { duration = 3000, hl = "DiagnosticHint" },
      TRACE = { duration = 3000, hl = "DiagnosticOk" },
      OFF   = { duration = 2000, hl = "Comment" },
    },
    max = {
      width = {
        absolute = 60,
        relative = 0.38,
      },
      height = {
        absolute = 20,
        relative = 0.3,
      },
    },
    winconfig = {
      noautocmd = true,
      focusable = false,
      zindex = 50,
      title = "",
      style = "minimal",
      border = { "╭", "─", "─", " ", "─", "─", "╰", "│" },
      relative = "editor",
      anchor = "NE",
      col = 99999,
      row = 1,
    },
  }
  M.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  vim.api.nvim_create_user_command("Notifications",
    function(_)
      for k, notification in pairs(M.log) do
        vim.print(k .. ":")
        for _, line in ipairs(notification.lines) do
          vim.print(line)
        end
      end
    end, { force = true }
  )

  local levels = {}
  for k, v in pairs(vim.log.levels) do
    levels[v] = default_opts.levels[k] or default_opts.levels.INFO
  end

  vim.notify = vim.schedule_wrap(
    function(msg, lvl)
      lvl = lvl or vim.log.levels.INFO
      local level = levels[lvl]

      if level.duration > 0 then
        local notification = {
          lines = vim.split(msg, "\n", { trimempty = true }),
          hl = level.hl or "Normal",
        }
        local key = M.next
        M.log[key] = notification
        M.queue[key] = notification
        M.next = M.next + 1
        M.refresh()

        vim.defer_fn(
          function()
            M.queue[key] = nil
            M.refresh()
          end, level.duration + 10)
      end
    end
  )
end

return M
