local M = { last_term = nil }

function M.close_all()
  local terms = require("toggleterm.terminal").get_all(true)
  for _, term in ipairs(terms) do
    term:close()
  end
end

function M.select()
  vim.ui.select(
    require("toggleterm.terminal").get_all(true),
    {
      hints = {
        show = true,
        chars = "asdferuio",
      },
      pipe = {
        sort = function(t1, t2)
          return t2.id > t1.id
        end,
      },
      format_item = {
        separator = " ",
        columns = { "id", "display_name" },
        justify = { "r", "l" },
        hl = { "Character", "Normal" },
      },
      keys = {
        create = { "<CR>", "c" },
      },
    },
    function(term, _, key)
      if term then
        if key == "c" then
          term:shutdown()
          M.select()
        else
          term:open()
          term:set_mode("i")
          M.last_term = term
        end
      end
    end
  )
end

function M.open(opts)
  if not opts then opts = {} end

  local dir = vim.api.nvim_buf_get_name(0) or vim.fn.getcwd()
  local bufname = vim.api.nvim_buf_get_name(0)
  local termdict = {
    Code = {
      mode = "hide",
      display_name = "Code",
      cmd = "opencode",
      dir = "git_dir",
    },
    Yazi = {
      mode = "hide",
      display_name = "Yazi",
      cmd = string.format("yazi '%s'", vim.fn.fnameescape(dir)),
      dir = "%:h",
    },
    Run = {
      mode = "wipe",
      display_name = "Run",
      cmd = bufname,
      dir = "%:h",
      close_on_exit = false
    },
    LazyGit = {
      mode = "hide",
      display_name = "LazyGit",
      cmd = "lazygit",
      dir = "git_dir",
    },
    ["LGFilter"] = {
      mode = "wipe",
      display_name = "LGFilter",
      cmd = "lazygit --filter " .. bufname,
      dir = "git_dir"
    },
    Shell = {
      mode = "",
      display_name = "Shell",
      cmd = "zsh",
      dir = "%:h",
    },
  }

  local cur_terms = require("toggleterm.terminal").get_all(true)
  for _, term in ipairs(cur_terms) do
    if term.display_name ~= "Shell" and termdict[term.display_name] then
      termdict[term.display_name].current = term
    end
  end

  local function on_choice(term, _)
    if not term then return end
    local newterm = term.current
    if not newterm then
      newterm = require("toggleterm.terminal").Terminal:new(term)
      newterm.on_open = function(nt)
        vim.keymap.set({ "t" }, "<C-l>", function() nt:close() end,
          { buffer = nt.bufnr, noremap = true, silent = true, desc = "Close" })
        vim.bo[nt.bufnr].bufhidden = term.mode
      end
    end

    newterm:open()
    newterm:set_mode("i")
    M.last_term = newterm
  end

  if opts.choice then
    local term = termdict[opts.choice]
    if termdict[opts.choice] and not term.created then
      on_choice(termdict[opts.choice])
    end
    return
  end

  local termlist = {}
  for _, term in pairs(termdict) do
    if not opts.skip or not term.current then
      table.insert(termlist, term)
    end
  end

  vim.ui.select(
    termlist,
    {
      hints = {
        show = true,
        chars = "cflrse",
      },
      pipe = {
        sort = function(t1, t2) return t1.display_name < t2.display_name end,
      },
      format_item = {
        separator = "  ",
        columns = { "display_name" },
        justify = { "l" },
        hl = { "Normal" },
      },
    },
    on_choice
  )
end

return M
