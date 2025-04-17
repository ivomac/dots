local M = {}

-- Save current session as "name"
local function save_session(session)
  -- Update global variable
  vim.g.session_info = session

  -- Save the session
  vim.cmd("mksession! " .. vim.fn.fnameescape(session.path))

  -- Append buffer variables
  local restore_template = "lua pcall(vim.api.nvim_buf_set_var, vim.fn.bufnr('%s'), '%s', %s)"

  local restore_cmds = {}
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    for varname, varval in pairs(buf.variables) do
      local vartype = type(varval)
      local starts_uppercase = varname:sub(1, 1):match("%u")
      if starts_uppercase and vim.tbl_contains(M.opts.savevartype, vartype) then
        if vartype == "table" then
          varval = vim.inspect(varval, { newline = " ", indent = " " })
        elseif vartype == "string" then
          varval = vim.fn.escape(varval, "'")
          local lines = vim.split(varval, "\n")
          local esc_lines = vim.tbl_map(function(line) return string.format("'%s'", line) end, lines)
          local args = table.concat(esc_lines, ", ")
          varval = string.format("table.concat({ %s }, '\\n')", args)
        end
        local restore_cmd = string.format(restore_template, buf.name, varname, varval)
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
end

-- Unload current session
local function unload_current_session()
  vim.g.session_info = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local function load_session(session)
  if vim.g.session_info then
    -- Save and unload current session
    save_session(vim.g.session_info)
    unload_current_session()
  end

  -- Load the session
  vim.cmd("silent! source " .. vim.fn.fnameescape(session.path))

  -- Update global
  vim.g.session_info = session
end

-- List all available sessions
local function list_sessions()
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
    return nil
  end

  return sessions
end

-- Unload current session
function M.unload()
  local session = vim.g.session_info

  if not session then
    vim.notify("No session loaded.", vim.log.levels.INFO)
  else
    unload_current_session()
    vim.notify("Session unloaded: " .. session.name, vim.log.levels.INFO)
  end
end

-- Save session
function M.save()
  if vim.g.session_info then
    -- Save current
    save_session(vim.g.session_info)
    vim.notify("Session saved: " .. vim.g.session_info.name, vim.log.levels.INFO)
  else
    -- Save new
    vim.ui.input(
      { prompt = "New session:" },
      function(name)
        if name == "" then
          vim.notify("Session save cancelled", vim.log.levels.INFO)
          return
        end

        local session = {
          name = name,
          path = string.format("%s/%s.vim", M.opts.folder, name),
        }

        -- Check if file exists and prompt for overwrite
        if vim.fn.filereadable(session.path) == 1 then
          local overwrite = vim.fn.input("Session '" .. session.name .. "' already exists. Overwrite? [y/N]: ")
          if overwrite:lower() ~= "y" then
            vim.notify("Session save cancelled", vim.log.levels.INFO)
            return
          end
        end

        save_session(session)
        vim.notify("Session saved: " .. vim.g.session_info.name, vim.log.levels.INFO)
      end
    )
  end
end

-- Delete a session
function M.delete()
  local sessions = list_sessions()
  if not sessions then
    vim.notify("No sessions found.", vim.log.levels.INFO)
    return
  end

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

-- Search and load a session
function M.load()
  local sessions = list_sessions()
  if not sessions then
    vim.notify("No sessions found.", vim.log.levels.INFO)
    return
  end

  vim.ui.select(
    sessions,
    {
      prompt = "Session:",
      format_item = function(item) return item.name end,
    },
    function(session, _)
      if session then
        load_session(session)
        vim.notify("Session loaded: " .. session.name, vim.log.levels.INFO)
      end
    end
  )
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force",
    {
      folder = vim.fn.stdpath("data") .. "/sessions",
      autosave = true,
      savevartype = {"string", "number"},
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
        for _, func in ipairs({ "save", "load", "unload", "delete" }) do
          if vim.startswith(func, arg) then
            table.insert(matches, func)
          end
        end
        return matches
      end,

    }
  )

  -- Set up auto-save on exit
  if M.opts.autosave then
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
end

return M
