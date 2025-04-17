local M = {}

function M.input(opts, on_confirm)
  opts = vim.tbl_deep_extend("force", vim.deepcopy(M.default_opts, true), opts or {})
  opts.win_opts.title = opts.win_opts.title or opts.prompt or ""

  -- Buffer
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "ui-input"

  opts.win_opts.width = math.max(opts.win_opts.width, #opts.win_opts.title)
  if opts.default then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.default })
    opts.win_opts.width = math.max(opts.win_opts.width, #opts.default + opts.extend_width)
  end

  -- Float window

  local win = vim.api.nvim_open_win(buf, true, opts.win_opts)

  vim.wo[win].foldenable = false
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.wo[win].sidescrolloff = 0

  -- Start in insert
  vim.cmd("startinsert!")

  -- Mappings
  local function get_input()
    return vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
  end

  local function accept(content)
    vim.api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
    on_confirm(content)
  end

  local map_opts = { nowait = true, buffer = buf }

  -- Exit with Esc on normal, Accept on Enter
  vim.keymap.set("n", "<Esc>", function() accept(nil) end, map_opts)
  vim.keymap.set({ "n", "i" }, "<CR>", function() accept(get_input()) end, map_opts)

  -- Autocmd to extend width as we type if needed
  local function extend_width()
    local line = get_input()
    if #line + opts.extend_margin > opts.win_opts.width then
      opts.win_opts.width = #line + opts.extend_width
      vim.api.nvim_win_set_config(win, { width = opts.win_opts.width })
    end
  end

  vim.api.nvim_create_autocmd({ "InsertCharPre" },
    {
      group = vim.api.nvim_create_augroup("UIInput", { clear = true }),
      buffer = buf,
      callback = extend_width
    }
  )

  return win, buf
end

function M.setup(opts)
  M.default_opts = {
    extend_margin = 3,
    extend_width = 10,
    win_opts = {
      relative = "cursor",
      row = 0,
      col = 0,
      width = 10,
      height = 1,
      style = "minimal",
      border = "rounded",
      title_pos = "center",
    }
  }

  if opts then
    M.default_opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})
  end

  vim.ui.input = M.input
end

return M
