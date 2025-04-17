local M = {}

-- Save current session
function M.save()
  local session = vim.g.session_info

  if not session then
    local session_name = vim.fn.input({ prompt = "New session: " })
    session = {
      name = session_name,
      path = string.format("%s/%s.vim", M.opts.folder, session_name),
    }

    if session.name == "" then
      vim.notify("Session save cancelled", vim.log.levels.INFO)
      return
    end

    -- Check if file exists and prompt for overwrite
    if vim.fn.filereadable(session.path) == 1 then
      local overwrite = vim.fn.input("Session '" .. session.name .. "' already exists. Overwrite? [y/N]: ")
      if overwrite:lower() ~= "y" then
        vim.notify("Session save cancelled", vim.log.levels.INFO)
        return
      end
    end
  end

  -- Update global variable
  vim.g.session_info = session

  -- Save the session
  vim.cmd("mksession! " .. vim.fn.fnameescape(session.path))

  -- Append buffer variables
  local restore_template = 'lua local n = vim.fn.bufnr("%s"); if n ~= -1 then vim.b[n].%s = %s end'

  local restore_cmds = {}
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    for name, value in pairs(buf.variables) do
      if vim.tbl_contains(M.opts.savevars, name) then
        if type(value) == "table" then
          value = vim.inspect(value)
        elseif type(value) == "string" then
          value = vim.fn.escape(value, '"')
          value = string.format('"%s"', value)
        end
        local restore_cmd = string.format(restore_template, buf.name, name, value)
        table.insert(restore_cmds, restore_cmd)
      end
    end
  end

  local file = io.open(session.path, "a")
  if file then
    for _, cmd in ipairs(restore_cmds) do
      file:write("\n" .. cmd)
    end
    file:close()
  end

  vim.notify("Session saved: " .. session.name, vim.log.levels.INFO)
end

-- Unload current session without saving
function M.unload()
  local session = vim.g.session_info

  if not session then return end

  vim.notify("Session unloaded: " .. session.name, vim.log.levels.INFO)
  vim.g.session_info = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

function M.load(session)
  if vim.g.session_info then
    M.save()
  end

  -- Unload current session
  M.unload()

  -- Load the session
  vim.cmd("silent! source " .. vim.fn.fnameescape(session.path))

  -- Update global
  vim.g.session_info = session

  vim.notify("Session loaded: " .. session.name, vim.log.levels.INFO)
end

-- List all available sessions
function M.list()
  local sessions = {}
  local session_files = vim.fn.glob(M.opts.folder .. "/*.vim", false, true)

  -- Sort files by last modified time (most recent first)
  table.sort(session_files, function(a, b)
    local stat_a = vim.uv.fs_stat(a)
    local stat_b = vim.uv.fs_stat(b)
    if stat_a and stat_b then
      return stat_a.mtime.sec > stat_b.mtime.sec
    end
    return false
  end)

  for _, file_path in ipairs(session_files) do
    local session_name = vim.fn.fnamemodify(file_path, ":t:r")
    if session_name then
      table.insert(sessions, {
        name = session_name,
        path = file_path
      })
    end
  end

  if #sessions == 0 then
    vim.notify("No sessions found", vim.log.levels.INFO)
    return nil
  end

  return sessions
end

-- Delete a session
function M.delete()
  local sessions = M.list()
  if not sessions then return end

  vim.ui.select(
    sessions,
    {
      prompt = "Delete session:",
      format_item = function(item) return item.name end,
    },
    function(session, _)
      if not session then return end

      -- Delete the file
      vim.fn.delete(session.path)

      if vim.g.session_info and vim.g.session_info.path == session.path then
        M.unload()
      end

      vim.notify("Session deleted: " .. session.name, vim.log.levels.INFO)
    end
  )
end

-- Search and select a session
function M.search()
  local sessions = M.list()
  if not sessions then return end

  vim.ui.select(
    sessions,
    {
      prompt = " Session ",
      format_item = function(item) return item.name end,
    },
    function(session, _)
      if not session then return end
      M.load(session)
    end
  )
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force",
    {
      folder = vim.fn.stdpath("data") .. "/sessions",
      savevars = {},
    },
    opts or {}
  )

  -- Ensure sessions directory exists
  vim.fn.mkdir(M.opts.folder, "p")

  -- Create user command
  vim.api.nvim_create_user_command("Session",
    function(cmd)
      M[cmd.fargs[1]]()
    end,
    {
      nargs = 1,
      complete = function(arg, _)
        local matches = {}
        for _, func in ipairs({ "save", "search", "delete" }) do
          if vim.startswith(func, arg) then
            table.insert(matches, func)
          end
        end
        return matches
      end,

    }
  )

  -- Set up auto-save on exit
  vim.api.nvim_create_autocmd({ "VimLeavePre" },
    {
      group = vim.api.nvim_create_augroup("SESSIONS", { clear = true }),
      callback = function()
        if vim.g.session_info then
          M.save()
        end
      end,
    }
  )
end

return M
