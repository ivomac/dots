local M = {}
M.terms = {}

function M.close_all()
  for _, term in pairs(M.terms) do
    term:close()
  end
end

function M.get(opts, mode)
  if not mode then mode = "hide" end

  if M.terms[opts.cmd] then
    return M.terms[opts.cmd]
  else
    M.terms[opts.cmd] = M.new(opts, mode)
    return M.terms[opts.cmd]
  end
end

function M.new(opts, mode)
  opts = vim.tbl_deep_extend("force",
    {
      hidden = true,
      direction = "float",
    },
    opts or {}
  )
  local new_term = require("toggleterm.terminal").Terminal:new(opts)

  local function on_create()
    vim.keymap.set({ "n", "t" }, "<C-l>", M.close_all,
      { buffer = new_term.bufnr, noremap = true, silent = true, desc = "Close terminal" })
    vim.bo[new_term.bufnr].bufhidden = mode
  end

  local function on_open()
    new_term:set_mode("i")
  end

  new_term.on_open = on_open
  new_term.on_create = on_create

  return new_term
end

-- Shell
function M.shell()
  M.get({}):open()
  vim.keymap.set("x", "<C-j><C-j>",
    function()
      require("toggleterm").send_lines_to_terminal("visual_lines", false, { args = M.terms.term.id })
    end,
    { noremap = true, silent = true, desc = "Send visual lines to terminal" }
  )
end

-- Run file
function M.run()
  local bufname = vim.api.nvim_buf_get_name(0)
  vim.cmd("silent !chmod +x" .. bufname)
  M.new({ cmd = bufname, close_on_exit = false }):open()
end

-- Explorer
function M.explorer(file)
  local cmd = "yazi " .. (file or vim.api.nvim_buf_get_name(0) or vim.fn.getcwd())
  M.get({ cmd = cmd }, "wipe"):open()
end

-- LazyGit
function M.lazygit()
  M.get({ cmd = "lazygit", dir = "git_dir" }):open()
end

function M.lazygitfilter()
  local cmd = "lazygit --filter " .. vim.api.nvim_buf_get_name(0)
  M.get({ cmd = cmd, dir = "git_dir" }, "wipe"):open()
end

-- Aider
function M.aider()
  M.get({ cmd = "aid", dir = "git_dir" }):open()
end

return M
