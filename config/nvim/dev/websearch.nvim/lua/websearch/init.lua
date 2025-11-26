local get_visual_selection = function()
  vim.fn.feedkeys(":", "nx")
  local mode = vim.fn.visualmode()
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")
  local lines = vim.fn.getregion(vstart, vend, { type = mode })
  return vim.fn.join(lines, "  ")
end

local M = {}

function M.search(url)
  -- If url is only white space, do not search.
  if url:match("^%s*$") then
    return
  end
  vim.notify("Searching " .. url, vim.log.levels.INFO)
  if url:sub(1, 4) ~= "http" then
    url = string.format(M.opts.search_url, url)
  end
  local cmd = vim.deepcopy(M.opts.browser, true)
  table.insert(cmd, url)
  vim.system(cmd, { detach = true })
end

function M.search_word()
  M.search(vim.fn.expand("<cfile>"))
end

function M.search_visual()
  M.search(get_visual_selection())
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force",
    {
      browser = {"xdg-open"},
      search_url = "https://www.google.com/search?q=%s"
    },
    opts
  )
end

return M
