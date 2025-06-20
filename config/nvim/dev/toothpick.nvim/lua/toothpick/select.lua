local M = {}


---@alias key string|integer
---@alias justify_dir "l"|"r"|"c"
---@alias hlgetter string|fun(item: any): string

---@class ConfigKeys
-- Keys to accept selection: will call on_choice(item, idx, key)
---@field accept string[]
-- Keys to cancel selection: will call on_choice(nil, nil, key)
---@field cancel string[]

---@class ConfigPipe
-- Filter function to preselect items (kept on true)
---@field filter nil|fun(a: any): boolean
-- Sort function to sort input table.
---@field sort nil|fun(a: any, b: any): boolean
-- Transform each item to sort input table.
---@field transform nil|fun(a: any): any

---@class ConfigFormatTable
-- string used to separate columns
---@field separator string
-- keys of input to use as columns
---@field columns key[]
-- justification per column: "l", "r", "c"
---@field justify justify_dir[]
-- highlight groups per column
---@field hl hlgetter[]

---@class ConfigHints
-- Letters used for line selection
---@field chars string
-- Show the letters as first column
---@field show boolean
-- Hint char highlight group
---@field hl string
-- string between hints and items
---@field separator string

---@class Config
--- Prompt will be used as window title
---@field prompt string
-- Highlight namespace for vim.api.nvim_create_namespace
---@field namespace string
-- Hints configuration
---@field hints table
-- Window config for vim.api.nvim_open_win
-- "width" here will be the minimum value
---@field winconfig table
-- Temporary vim.opt.guicursor used inside window
-- Set to nil to not hide the cursor
---@field guicursor string
---@field pipe ConfigPipe
-- Format item function.
-- A table is accepted to format the inputs as a table:
-- format_item = {
--   separator = " ",
--   columns = { 1, "name", "dir" },
--   justify = { "l", "r", "r" },
--   hl = { "Normal", "Comment", "MyOwnHighlight" },
-- },
---@field format_item ConfigFormatTable|fun(a: any): string
-- Keys to bind
---@field keys ConfigKeys


local function justify(str, len, dir)
  local padsize = len - #str
  if dir == "l" then
    return str .. string.rep(" ", padsize)
  elseif dir == "r" then
    return string.rep(" ", padsize) .. str
  elseif dir == "c" then
    local lpadsize = math.floor(padsize / 2)
    local rpadsize = math.ceil(padsize / 2)
    return string.rep(" ", lpadsize) .. str .. string.rep(" ", rpadsize)
  end
end

-- vim.ui.select replacement
---@generic T
---@param items T[]  list of items to choose from
---@param config table  options dictionary
---@param on_choice fun(item: T|nil, idx: integer|nil, key: string)  function to call on chosen item
---@return integer|nil win  window integer identifier
---@return integer[]|nil buf  list of buffer integer identifiers
function M.select(items, config, on_choice)
  if #items == 0 then
    vim.print("No items to choose from.")
    return nil, nil
  end

  config = vim.tbl_deep_extend("force", vim.deepcopy(M.config, true), config or {})

  -- Filter items
  local fitems = {}
  if config.pipe.filter then
    for _, item in ipairs(items) do
      if config.pipe.filter(item) then
        table.insert(fitems, item)
      end
    end
  else
    fitems = items
  end

  if #fitems == 0 then
    vim.print("No items to choose from after filter.")
    return nil, nil
  end

  -- Sort items
  if config.pipe.sort then
    table.sort(fitems, config.pipe.sort)
  end

  -- Transform items
  items = {}
  if config.pipe.transform then
    for _, buf in ipairs(fitems) do
      table.insert(items, config.pipe.transform(buf))
    end
  else
    items = fitems
  end

  -- get the hint character for line number
  local function get_line_char(nline)
    return config.hints.chars:sub(nline, nline)
  end

  -- get the hint character for item number
  local function get_item_char(nitem)
    return get_line_char(((nitem - 1) % #config.hints.chars) + 1)
  end

  local function get_item_prefix(nitem)
    local char = get_item_char(nitem)
    return string.format("%s%s", char, config.hints.separator)
  end

  local hlranges = {}

  local start_col = 0
  local stop_col
  if config.hints.show then
    table.insert(hlranges, { group = config.hints.hl, start = 0, stop = 1 })
    start_col = 1 + #config.hints.separator
  end

  local format
  if type(config.format_item) == "table" then
    local colsizes = {}
    for _, item in ipairs(items) do
      for _, col in ipairs(config.format_item.columns) do
        colsizes[col] = math.max(colsizes[col] or 0, #tostring(item[col]))
      end
    end

    for g, group in ipairs(config.format_item.hl) do
      stop_col = start_col + colsizes[config.format_item.columns[g]]
      table.insert(hlranges, { group = group, start = start_col, stop = stop_col })
      start_col = stop_col + #config.format_item.separator
    end

    format = function(item, nitem)
      local justified_lines = {}
      if config.hints.show then
        table.insert(justified_lines, get_item_prefix(nitem))
      end
      for ncol, col in ipairs(config.format_item.columns) do
        table.insert(justified_lines,
          justify(tostring(item[col]), colsizes[col], config.format_item.justify[ncol]))
      end
      return table.concat(justified_lines, config.format_item.separator)
    end
  else
    format = config.format_item
  end

  -- Lists of items
  -- Items are separated in pages of size equal to #opts.hints.chars
  local lists = {}
  local cur_list = {}
  local max_linewidth = 0

  for i, item in ipairs(items) do
    -- Start new list if current is full
    if #cur_list >= #config.hints.chars then
      table.insert(lists, cur_list)
      cur_list = {}
    end


    local line = format(item, i)

    table.insert(cur_list, line)

    max_linewidth = math.max(#line, max_linewidth)
  end
  table.insert(lists, cur_list)

  -- Create buffers
  local bufs = {}
  local hl_ns = vim.api.nvim_create_namespace(config.namespace)

  for nlist, list in ipairs(lists) do
    local buf = vim.api.nvim_create_buf(false, true)
    table.insert(bufs, buf)

    -- Buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)

    -- Buffer options
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "ui-select"

    -- Add highlights
    for nline = 1, #list do
      for _, hl in ipairs(hlranges) do
        local group = hl.group
        if type(group) == "function" then
          local nitem = nline + (nlist - 1) * config.winconfig.height
          group = group(items[nitem], nitem)
        end
        vim.hl.range(buf, hl_ns, hl.group, { nline - 1, hl.start }, { nline - 1, hl.stop })
      end
    end
  end

  -- Create float window
  local wconfig = config.winconfig
  wconfig.title = wconfig.title or config.prompt or ""
  wconfig.height = math.min(#items, #config.hints.chars)
  wconfig.width = math.max(max_linewidth, #wconfig.title)

  if #lists > 1 then
    wconfig.footer = "1/" .. #lists
  end

  local win = vim.api.nvim_open_win(bufs[1], true, wconfig)

  -- Load user highlight namespace
  vim.api.nvim_win_set_hl_ns(win, hl_ns)

  -- Window options
  vim.wo[win].foldenable = false
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].sidescrolloff = 0

  -- Hide the cursor by setting guicursor
  -- Guicursor can't be set locally
  -- Set globally and restore on exit
  local saved_guicursor = vim.opt.guicursor
  if config.guicursor then
    vim.opt.guicursor = config.guicursor
  end

  -- Exit and select function
  local function select(nitem, key)
    -- Close window
    vim.api.nvim_win_close(win, true)
    for _, buffer in ipairs(bufs) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end

    -- Reset cursor
    vim.opt.guicursor = saved_guicursor

    -- Trigger on_choice
    if nitem then
      on_choice(items[nitem], nitem, key)
    else
      on_choice(nil, nil, key)
    end
  end

  -- Keymaps
  for nbuf, buf in ipairs(bufs) do
    local map_opts = { nowait = true, buffer = buf }

    -- Cancel
    for _, key in ipairs(config.keys.cancel) do
      vim.keymap.set("n", key, function() select(nil, key) end, map_opts)
    end

    -- Accept
    for _, key in ipairs(config.keys.accept) do
      vim.keymap.set("n", key,
        function()
          select(vim.api.nvim_win_get_cursor(win)[1] + (nbuf - 1) * wconfig.height, key)
        end,
        map_opts
      )
    end

    -- Line hint keymaps
    for nline = 1, #lists[nbuf] do
      local key = get_line_char(nline)
      local nitem = nline + (nbuf - 1) * wconfig.height
      vim.keymap.set("n", key, function() select(nitem, key) end, map_opts)
    end

    -- Page change keymaps
    for _, target in ipairs({ { char = "h", idx = nbuf - 1 }, { char = "l", idx = nbuf + 1 } }) do
      if bufs[target.idx] then
        vim.keymap.set("n", target.char,
          function()
            vim.api.nvim_win_set_buf(win, bufs[target.idx])
            if #lists > 1 then
              vim.api.nvim_win_set_config(win, { footer = target.idx .. "/" .. #lists })
              vim.wo[win].cursorline = true
            end
          end,
          map_opts
        )
      end
    end

    -- Autocmd to close win on focus loss
    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end,
      buffer = buf,
      once = true,
    })
  end

  return win, bufs
end

---@param config table
function M.setup(config)
  ---@type Config
  local default_config = {
    prompt = "",
    format_item = tostring,
    keys = {
      accept = { "<CR>" },
      cancel = { "<Esc>", "q" },
    },
    namespace = "UISelect",
    hints = {
      show = true,
      chars = "asdf",
      hl = "MoreMsg",
      separator = " ",
    },
    winconfig = {
      relative = "cursor",
      row = 0,
      col = 0,
      width = 5,
      style = "minimal",
      border = "rounded",
      title_pos = "left",
      footer = "",
      footer_pos = "center",
    },
    guicursor = "n:UIHiddenCursor",
    pipe = {
      filter = nil,
      sort = nil,
      transform = nil,
    },
  }
  M.config = vim.tbl_deep_extend("force",
    default_config,
    config or {}
  )

  vim.api.nvim_set_hl(0, "UIHiddenCursor", { reverse = true, blend = 100 })

  vim.ui.select = M.select
end

return M
