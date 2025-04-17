local M = {}

function M.git_files()
  local files = vim.fn.systemlist("git ls-files --full-name")
  local readable_files = {}

  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      table.insert(readable_files, file)
    end
  end
  return readable_files
end

function M.load_git_files()
  for _, file in ipairs(M.git_files()) do
    vim.fn.bufadd(vim.fn.fnamemodify(file, ":p"))
  end
end

function M.chdir(dest)
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
  local short_path = vim.fn.pathshorten(dest_path, 3)
  local last_dir = vim.fn.chdir(dest_path)
  if last_dir == "" then
    vim.notify("cd failed: " .. dest_path, vim.log.levels.WARN)
  else
    vim.notify("cd " .. short_path, vim.log.levels.INFO)
  end
end

function M.modified(buf)
  if vim.bo[buf].modified then
    vim.notify(string.format("Buffer has unsaved changes.", vim.log.levels.WARN))
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
    return true
  end
  return false
end

function M.bufdel(buf, opts)
  if not opts.force and M.modified(buf) then return end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win,
      function()
        local lastbuf = vim.fn.bufnr("#")

        if lastbuf ~= buf and vim.fn.buflisted(lastbuf) == 1 then
          vim.api.nvim_win_set_buf(win, lastbuf)
        else
          local newbuf = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_win_set_buf(win, newbuf)
        end
      end
    )
  end

  vim.api.nvim_buf_delete(buf, opts)
end

function M.delete(buf, opts)
  if not opts.force and M.modified(buf) then return end

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")

  local code = vim.fn.delete(path)
  if code == 0 then
    vim.notify("Deleted " .. path, vim.log.levels.INFO)

    M.bufdel(buf, opts)
  else
    vim.notify(string.format("Deletion failed: %s", code), vim.log.levels.ERROR)
  end
end

local function remove_common_prefix(path1, path2)
  local parts1 = vim.split(path1, "/", { plain = true, trimempty = true })
  local parts2 = vim.split(path2, "/", { plain = true, trimempty = true })

  local i = 1
  while i <= #parts1 and i <= #parts2 and parts1[i] == parts2[i] do
    i = i + 1
  end

  local unique1_parts = vim.list_slice(parts1, i)
  local unique2_parts = vim.list_slice(parts2, i)

  local unique1 = table.concat(unique1_parts, "/")
  local unique2 = table.concat(unique2_parts, "/")

  return unique1, unique2
end

function M.rename(buf, newpath, opts)
  if not buf or not newpath then return end
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")

  if not opts.force and M.modified(buf) then return end

  if vim.fn.isabsolutepath(newpath) == 0 then
    local folder = vim.fn.fnamemodify(path, ":h")
    newpath = string.format("%s/%s", folder, newpath)
  end
  newpath = vim.fn.fnamemodify(newpath, ":p")

  if vim.fn.filereadable(newpath) == 1 then
    vim.notify("Rename: new file path already exists. " .. newpath, vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(newpath, ":h"), "p")

  vim.api.nvim_buf_set_name(buf, newpath)
  vim.api.nvim_buf_call(buf, function() vim.cmd("silent write!") end)

  local prev_buf = vim.fn.bufnr(path)
  if prev_buf ~= -1 then
    vim.api.nvim_buf_delete(prev_buf, { force = true })
  end

  local code = vim.fn.delete(path)

  if code == 0 then
    path, newpath = remove_common_prefix(path, newpath)
    vim.notify(string.format("Rename:\nold: %s\nnew: %s", path, newpath), vim.log.levels.INFO)
  else
    vim.notify(string.format("Rename failed: %s", code), vim.log.levels.ERROR)
  end
end

function M.rename_ui(buf, opts)
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")
  vim.ui.input(
    { prompt = "Rename", default = path },
    function(newpath) M.rename(buf, newpath, opts) end
  )
end

function M.chmod(buf, mode)
  local path = vim.api.nvim_buf_get_name(buf)
  vim.uv.fs_chmod(path, tonumber(mode, 8))
end

function M.setup()
  local function bufget(args)
    local buf = args.fargs[1] or 0
    if type(buf) == "string" then
      buf = vim.fn.bufnr(buf)
    end
    return buf
  end

  vim.api.nvim_create_user_command("Bwipeout",
    function(args)
      M.bufdel(bufget(args), { force = args.bang })
    end,
    { bang = true, nargs = "?", force = true }
  )

  vim.api.nvim_create_user_command("Bunload",
    function(args)
      M.bufdel(bufget(args), { force = args.bang, unload = true })
    end,
    { bang = true, nargs = "?", force = true }
  )

  vim.api.nvim_create_user_command("Delete",
    function(args)
      local buf = vim.api.nvim_get_current_buf()
      local relpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")

      local confirm = vim.fn.input(
        {
          prompt = string.format("Delete %s [Y/n]: ", relpath),
          cancelreturn = "n"
        }
      ):lower()

      if confirm == "n" then
        return
      end

      M.delete(buf, { force = args.bang })
    end,
    { bang = true, nargs = 0, force = true }
  )

  vim.api.nvim_create_user_command("Rename",
    function(args)
      local buf = vim.api.nvim_get_current_buf()
      local opts = { force = args.bang }

      if args.fargs[1] then
        M.rename(buf, args.fargs[1], opts)
      else
        M.rename_ui(buf, opts)
      end
    end,
    { bang = true, nargs = "?", force = true }
  )

  vim.api.nvim_create_user_command("Chmod",
    function(opts) M.chmod(0, opts.fargs[1]) end,
    { nargs = 1 }
  )

  vim.api.nvim_create_autocmd("BufWritePost",
    {
      group = vim.api.nvim_create_augroup("AUTO_CHMOD", { clear = true }),
      callback = function(ev)
        local first_line = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1]
        if first_line and first_line:match("^#!") then
          M.chmod(ev.buf, 0755)
        end
      end,
    }
  )

  M.did_autocd = false
  vim.api.nvim_create_autocmd({ "BufReadPost" },
    {
      group = vim.api.nvim_create_augroup("GIT_AUTOCD", { clear = true }),
      callback = function(args)
        if M.did_autocd then return end
        local buftype = vim.bo[args.buf].buftype
        local filetype = vim.bo[args.buf].filetype

        if buftype ~= "" or filetype == "help" or filetype == "man" then
          return
        end
        local ret = M.chdir("git")
        M.did_autocd = ret ~= ""
      end
    }
  )
end

M.setup()

return M
