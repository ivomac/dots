local M = {}

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
--- @param items any  items to choose from
--- @param opts table|nil  options dictionary
--- @param on_choice function  function to call on chosen item
--- @return integer|nil win  window integer identifier
--- @return integer[]|nil buf  table of buffer integer identifier
function M.select(items, opts, on_choice)
  if #items == 0 then
    vim.print("No items to choose from.")
    return nil, nil
  end

  opts = vim.tbl_deep_extend("force", vim.deepcopy(M.opts, true), opts or {})

  -- Filter items
  local fitems = {}
  if opts.filter then
    for _, item in ipairs(items) do
      if opts.filter(item) then
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
  if opts.sort then
    table.sort(fitems, opts.sort)
  end

  -- Transform items
  items = {}
  if opts.transform then
    for _, buf in ipairs(fitems) do
      table.insert(items, opts.transform(buf))
    end
  else
    items = fitems
  end

  local idx_to_chr = {}
  for i = 1, #opts.hints.chars do
    idx_to_chr[i - 1] = opts.hints.chars:sub(i, i)
  end

  local formatter
  if type(opts.format_item) == "table" then
    local tab = opts.format_item

    tab.colsizes = {}
    for _, item in ipairs(items) do
      for _, col in ipairs(tab.columns) do
        tab.colsizes[col] = math.max(tab.colsizes[col] or 0, #item[col])
      end
    end

    formatter = function(line)
      local justified_lines = {}
      for i, col in ipairs(tab.columns) do
        table.insert(justified_lines, justify(line[col], tab.colsizes[col], tab.justify and tab.justify[i] or "l"))
      end
      return table.concat(justified_lines, tab.separator)
    end
  else
    formatter = opts.format_item
  end

  -- Lists of items
  -- Items are separated in pages of size equal to #opts.hints.chars
  local lists = {}
  local cur_list = {}
  local max_linewidth = 0

  for i, item in ipairs(items) do
    -- Start new list if current is full
    if #cur_list >= #opts.hints.chars then
      table.insert(lists, cur_list)
      cur_list = {}
    end


    local line = formatter(item)
    if opts.hints.show then
      local letter = idx_to_chr[(i - 1) % #opts.hints.chars]
      line = string.format("%s%s%s", letter, opts.hints.separator, line)
    end

    table.insert(cur_list, line)

    max_linewidth = math.max(#line, max_linewidth)
  end
  table.insert(lists, cur_list)

  -- Create buffers
  local bufs = {}
  local hl_ns = vim.api.nvim_create_namespace(opts.namespace)

  for _, list in ipairs(lists) do
    local buf = vim.api.nvim_create_buf(false, true)
    table.insert(bufs, buf)

    -- Buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)

    -- Buffer options
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "ui-select"

    -- Add highlights
    for idx = 0, #list - 1 do
      local start_col = 0
      local end_col
      if opts.hints.show then
        vim.hl.range(buf, hl_ns, opts.hints.hl, { idx, 0 }, { idx, 1 })
        start_col = 1 + #opts.hints.separator
      end
      local tab = opts.format_item
      if type(tab) == "table" and tab.hl then
        for g, group in ipairs(tab.hl) do
          end_col = start_col + tab.colsizes[tab.columns[g]]
          vim.hl.range(buf, hl_ns, group, { idx, start_col }, { idx, end_col })
          start_col = end_col + #tab.separator
        end
      end
    end
  end

  -- Create float window
  local wconfig = opts.winconfig
  wconfig.title = wconfig.title or opts.prompt or ""
  wconfig.height = math.min(#items, #opts.hints.chars)
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
  if opts.guicursor then
    vim.opt.guicursor = opts.guicursor
  end

  -- Exit and select function
  local function select(line_idx, buf_idx, key)
    -- Close window
    vim.api.nvim_win_close(win, true)
    for _, buffer in ipairs(bufs) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end

    -- Reset cursor
    vim.opt.guicursor = saved_guicursor

    -- Trigger on_choice
    if line_idx and buf_idx then
      local item_idx = line_idx + 1 + (buf_idx - 1) * wconfig.height
      on_choice(items[item_idx], item_idx, key)
    else
      on_choice(nil, nil, key)
    end
  end

  -- Keymaps
  for buf_idx, buf in ipairs(bufs) do
    local map_opts = { nowait = true, buffer = buf }

    -- Cancel
    for _, key in ipairs(opts.cancel) do
      vim.keymap.set("n", key, function() select(nil, nil, key) end, map_opts)
    end

    -- on_choice mappings
    for _, key in ipairs(opts.on) do
      vim.keymap.set("n", key, function() select(vim.api.nvim_win_get_cursor(win)[1] - 1, buf_idx, key) end, map_opts)
    end

    -- User mappings

    -- Line hint keymaps
    for line_idx = 0, #lists[buf_idx] - 1 do
      local key = idx_to_chr[line_idx]
      vim.keymap.set("n", key, function() select(line_idx, buf_idx, key) end, map_opts)
    end

    -- Page change keymaps
    for _, target in ipairs({ { char = "h", idx = buf_idx - 1 }, { char = "l", idx = buf_idx + 1 } }) do
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

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force",
    {
      -- Prompt will be used as window title
      ---@type string
      prompt = "",
      -- Highlight namespace for vim.api.nvim_create_namespace
      ---@type string
      namespace = "UISelect",
      hints = {
        -- Letters used for line selection
        ---@type string
        chars = "asdf",
        -- Show the letters as first column
        ---@type boolean
        show = true,
        -- Hint char highlight group
        ---@type string
        hl = "MoreMsg",
        ---@type string
        separator = " ",
      },
      -- Window config for vim.api.nvim_open_win
      -- "width" here will be the minimum value
      ---@type table
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
      -- Temporary vim.opt.guicursor used inside window
      -- Set to nil to not hide the cursor
      ---@type string|nil
      guicursor = "n:UIHiddenCursor",
      -- Filter function to preselect items (kept on true)
      ---@type fun(a: any): boolean
      filter = nil,
      -- Sort function to sort input table.
      ---@type fun(a: any, b: any): boolean
      sort = nil,
      -- Transform each item to sort input table.
      ---@type fun(a: any): any
      transform = nil,
      -- A table is accepted to format the inputs as a table.
      ---@type table|fun(a: any): string
      -- format_item = {
      --   separator = " ",
      --   columns = { 1, "name", "dir" },
      --   justify = { "l", "r", "r" },
      --   hl = { "Normal", "Comment", "MyOwnHighlight" },
      -- },
      -- Format item function.
      format_item = tostring,
      -- Keys to select current line: will call on_choice(item, idx, key)
      ---@type string[]
      on = { "<CR>" },
      -- Keys to cancel selection: will call on_choice(nil, nil, key)
      ---@type string[]
      cancel = { "<Esc>" },
    },
    opts or {}
  )

  vim.api.nvim_set_hl(0, "UIHiddenCursor", { reverse = true, blend = 100 })

  vim.ui.select = M.select
end

return M
