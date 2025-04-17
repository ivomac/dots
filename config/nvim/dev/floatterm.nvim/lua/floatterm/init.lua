local M = { last_term = nil }

function M.close_all()
  local terms = require("toggleterm.terminal").get_all(true)
  for _, term in ipairs(terms) do
    term:shutdown()
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
          local time1 = vim.b[t1.bufnr].TS_tfocus
          local time2 = vim.b[t2.bufnr].TS_tfocus
          return time1 > time2
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

function M.new(choice)
  local dir = vim.api.nvim_buf_get_name(0) or vim.fn.getcwd()
  local bufname = vim.api.nvim_buf_get_name(0)
  local termdict = {
    Aider = {
      created = false,
      mode = "hide",
      display_name = "Aider",
      cmd = "aid",
      dir = "git_dir",
    },
    Yazi = {
      created = false,
      mode = "wipe",
      display_name = "Yazi",
      cmd = string.format("yazi '%s'", vim.fn.fnameescape(dir)),
      dir = "%:h",
    },
    Run = {
      created = false,
      mode = "wipe",
      display_name = "Run",
      cmd = bufname,
      dir = "%:h",
      close_on_exit = false
    },
    LazyGit = {
      created = false,
      mode = "hide",
      display_name = "LazyGit",
      cmd = "lazygit",
      dir = "git_dir",
    },
    ["LazyGit Filter"] = {
      created = false,
      mode = "wipe",
      display_name = "LazyGit Filter",
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
      termdict[term.display_name].created = true
    end
  end

  local function on_choice(term, _)
    if not term then return end
    local newterm = require("toggleterm.terminal").Terminal:new(term)
    newterm:open()

    vim.keymap.set({ "n", "t" }, "<C-l>", function() newterm:close() end,
      { buffer = newterm.bufnr, noremap = true, silent = true, desc = "Close" })
    vim.bo[newterm.bufnr].bufhidden = term.mode

    newterm:set_mode("i")
    M.last_term = newterm
  end

  if choice then
    local term = termdict[choice]
    if termdict[choice] and not term.created then
      on_choice(termdict[choice])
    end
    return
  end

  local termlist = {}
  for _, term in pairs(termdict) do
    if not term.created then
      table.insert(termlist, term)
    end
  end

  vim.ui.select(
    termlist,
    {
      hints = {
        show = true,
        chars = "asdferuio",
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
