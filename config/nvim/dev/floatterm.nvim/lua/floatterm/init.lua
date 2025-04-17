local M = {}
M.terms = {}
M.lastget = nil

function M.close_all()
  for _, term in pairs(M.terms) do
    term:close()
  end
end

function M.open(opts, mode)
  if not mode then mode = "hide" end

  M.lastget = { opts, mode }

  local term = M.terms[opts.cmd]
  if term then
    term:open()
    term:set_mode("i")
  else
    M.terms[opts.cmd] = M.open_new(opts, mode)
  end
end

function M.last()
  if M.lastget then
    return M.open(M.lastget[1], M.lastget[2])
  else
    M.shell()
  end
end

function M.open_new(opts, mode)
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

  new_term.on_create = on_create

  new_term:open()
  new_term:set_mode("i")
  return new_term
end

-- Shell
function M.shell()
  M.open({ cmd = "zsh", dir = "%:h" })

  vim.keymap.set("x", "<C-j><C-j>",
    function()
      require("toggleterm").send_lines_to_terminal("visual_lines", false, { args = M.terms["zsh"].id })
    end,
    { noremap = true, silent = true, desc = "Send visual lines to terminal" }
  )
end

-- Run file
function M.run()
  local bufname = vim.api.nvim_buf_get_name(0)
  vim.cmd("silent !chmod +x" .. bufname)
  M.open_new({ cmd = bufname, dir = "%:h", close_on_exit = false })
end

-- Explorer
function M.explorer()
  local cmd = "yazi " .. (vim.api.nvim_buf_get_name(0) or vim.fn.getcwd())
  M.open({ cmd = cmd }, "wipe")
end

-- LazyGit
function M.lazygit()
  M.open({ cmd = "lazygit", dir = "git_dir" })
end

function M.lazygitfilter()
  local cmd = "lazygit --filter " .. vim.api.nvim_buf_get_name(0)
  M.open({ cmd = cmd, dir = "git_dir" }, "wipe")
end

-- Aider
function M.aider()
  M.open({ cmd = "aid", dir = "git_dir" })
end

function M.setup()
  -- create user command
  vim.api.nvim_create_user_command("Explorer", M.explorer, {})
  vim.api.nvim_create_user_command("LazyGit", M.lazygit, {})
end

return M
