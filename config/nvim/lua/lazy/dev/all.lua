-- format time in "3h42m10s" format
local function format_time(time)
  local seconds = time % 60
  local minutes = math.floor((time % 3600) / 60)
  local hours = math.floor(time / 3600)
  if hours == 0 and minutes == 0 then
    return string.format("%ds", seconds)
  elseif hours == 0 then
    return string.format("%dm", minutes)
  else
    return string.format("%dh%02d", hours, minutes)
  end
end

local function buftransform(buf)
  local flag = ""
  if buf.changed == 1 then flag = flag .. "+" end
  local relative = vim.fn.fnamemodify(buf.name, ":p:~:.")
  local parent = vim.fn.fnamemodify(relative, ":h:t")
  local name = vim.fn.fnamemodify(relative, ":t")
  local rest = vim.fn.pathshorten(vim.fn.fnamemodify(relative, ":h:h"), 3)
  return {
    name = string.format("%s/%s%s", parent, name, flag),
    rest = rest,
    lastused = format_time(os.time() - buf.lastused) .. " ago",
    focus_time = format_time(math.floor((buf.variables.focus_time or 0) / 1000000000)),
    bufnr = buf.bufnr
  }
end

local function make_on_choice(opts)
  local function on_choice(buf, _, key)
    if not buf then return end
    if key == "r" or key == "p" or key == "u" then
      if key == "r" then
        vim.api.nvim_buf_delete(buf.bufnr, {})
      elseif key == "p" then
        vim.api.nvim_buf_set_var(buf.bufnr, "pinned", 1)
      elseif key == "u" then
        vim.api.nvim_buf_set_var(buf.bufnr, "pinned", 0)
      end

      vim.ui.select(
        vim.fn.getbufinfo({ buflisted = 1 }),
        opts,
        on_choice
      )
    else
      vim.api.nvim_set_current_buf(buf.bufnr)
    end
  end
  return on_choice
end

local function last_used_select()
  local opts = {
    filter = function(buf)
      return
          buf.hidden == 1
          and buf.loaded == 1
          and (os.time() - buf.lastused) < 300
    end,
    sort = function(buf1, buf2)
      return
          (buf1.pinned or 0) > (buf2.pinned or 0)
          or buf1.lastused > buf2.lastused
    end,
    transform = buftransform,
    prompt = " Buffers ",
    format_item = {
      separator = " ",
      columns = { "name", "rest", "lastused" },
      justify = { "l", "r", "l" },
      hl = { "Normal", "Character", "Comment" },
    },
    cancel = { "<Esc>" },
    on = { "<CR>", "r", "p" },
  }

  vim.ui.select(
    vim.fn.getbufinfo({ buflisted = 1 }),
    opts, make_on_choice(opts)
  )
end

local function focus_time_select()
  local opts = {
    filter = function(buf)
      return
          buf.variables.pinned == 1
          or (
            buf.hidden == 1
            and buf.loaded == 1
            and (buf.variables.focus_time or 0) > 0
          )
    end,
    sort = function(buf1, buf2)
      return
          (buf1.pinned or 0) > (buf2.pinned or 0)
          or buf1.variables.focus_time > buf2.variables.focus_time
    end,
    transform = buftransform,
    prompt = " Buffers ",
    format_item = {
      separator = " | ",
      columns = { "name", "rest", "focus_time" }, -- , "lastused"
      justify = { "l", "r", "l", "r" },
      hl = { "Normal", "Comment", "Character" },  -- , "Character"
    },
    cancel = { "<Esc>" },
    on = { "<CR>", "r", "p" },
  }

  vim.ui.select(
    vim.fn.getbufinfo({ buflisted = 1 }),
    opts, make_on_choice(opts)
  )
end

return {

  {
    "ivomac/pinboard.nvim",
    dev = true,
    event = { "VeryLazy" },
    opts = {},
  },

  {
    "ivomac/timesaver.nvim",
    dev = true,
    event = { "VeryLazy" },
    opts = {},
  },

  {
    "ivomac/cmp-neosnip",
    dev = true,
    opts = {
      folders = {
        vim.fn.stdpath("config") .. "/dev/cmp-neosnip/lua/cmp-neosnip/snippets",
      }
    },
  },

  {
    "ivomac/floatterm.nvim",
    dev = true,
    dependencies = { "akinsho/toggleterm.nvim" },
    keys = {
      { mode = { "n" }, "<leader>tt",  function() require("floatterm").shell() end,         silent = true, noremap = true, desc = "Toggle Term" },
      { mode = { "n" }, "<leader>tr",  function() require("floatterm").run() end,           silent = true, noremap = true, desc = "Run current script" },
      { mode = { "n" }, "<leader>te",  function() require("floatterm").explorer() end,      silent = true, noremap = true, desc = "Save" },
      { mode = { "n" }, "<leader>ta",  function() require("floatterm").aider() end,         silent = true, noremap = true, desc = "Aider" },
      { mode = { "n" }, "<leader>tlg", function() require("floatterm").lazygit() end,       silent = true, noremap = true, desc = "Lazygit" },
      { mode = { "n" }, "<leader>tlf", function() require("floatterm").lazygitfilter() end, silent = true, noremap = true, desc = "Lazygit filter" },
    },
  },

  {
    "ivomac/toothpick.nvim",
    dev = true,
    opts = {},
    keys = {
      {
        mode = { "n" },
        "mf",
        focus_time_select,
        silent = true,
        noremap = true,
        desc = "Change buffer by focus time",
      },
      {
        mode = { "n" },
        "ml",
        last_used_select,
        silent = true,
        noremap = true,
        desc = "Change buffer by last used",
      },
    },
  },

  {
    "ivomac/carboncopy.nvim",
    dev = true,
    dependencies = { "ivomac/toothpick.nvim" },
    opts = {
      folder = vim.fn.expand("~") .. "/Docs/.nvim/sessions",
      savevars = {
        "focus_time"
      },
    },
    cmd = { "Session" },
    keys = {
      { mode = { "n" }, "<leader>sf", function() require("carboncopy").search() end, silent = true, noremap = true, desc = "Search" },
      { mode = { "n" }, "<leader>sd", function() require("carboncopy").delete() end, silent = true, noremap = true, desc = "Delete" },
      { mode = { "n" }, "<leader>ss", function() require("carboncopy").save() end,   silent = true, noremap = true, desc = "Save" },
    },
  },

  {
    "ivomac/workout.nvim",
    dev = true,
    dependencies = { "ivomac/toothpick.nvim" },
    opts = {},
    cmd = { "Bunload", "Bwipeout", "Rename", "Delete" },
    keys = {
      { mode = { "n" }, "<leader>ww", function() require("workout").bufdel(0, {}) end,                silent = true, noremap = true, desc = "Buffer Wipe" },
      { mode = { "n" }, "<leader>wu", function() require("workout").bufdel(0, { unload = true }) end, silent = true, noremap = true, desc = "Buffer Unload" },
      { mode = { "n" }, "<leader>wr", function() require("workout").rename_ui(0, {}) end,             silent = true, noremap = true, desc = "File Rename" },
      { mode = { "n" }, "<leader>wd", function() require("workout").delete(0, {}) end,                silent = true, noremap = true, desc = "File Delete" },
      { mode = { "n" }, "<leader>wc", function() require("workout").chdir("current") end,             silent = true, noremap = true, desc = "cd %:h" },
      { mode = { "n" }, "<leader>wp", function() require("workout").chdir("parent") end,              silent = true, noremap = true, desc = "cd .." },
      { mode = { "n" }, "<leader>wg", function() require("workout").chdir("git") end,                 silent = true, noremap = true, desc = "cd git" },
      { mode = { "n" }, "<leader>we", function() require("workout").load_git_files() end,             silent = true, noremap = true, desc = "Load Git files" },
    },
  },

  {
    "ivomac/websearch.nvim",
    dev = true,
    opts = {
      browser = { "firefox", "-P", "default-release" },
      search_url = "https://www.google.com/search?q=%s&pws=0&gl=us&gws_rd=cr"
    },
    keys = {
      {
        mode = { "n" },
        "<CR>",
        function()
          if vim.bo.buftype == "" then
            require("websearch").search_word()
          else
            local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
            vim.api.nvim_feedkeys(enter, "nt", false)
          end
        end,
        silent = true,
        noremap = true,
        desc = "Search text"
      },
      {
        mode = { "x" },
        "<CR>",
        function() require("websearch").search_visual() end,
        silent = true,
        noremap = true,
        desc = "Search selection"
      },
    }
  },

}
