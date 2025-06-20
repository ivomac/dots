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
  if buf.changed == 1 then
    flag = "+"
  end
  if buf.variables.pinned == 1 then
    flag = "*"
  end
  local relative = vim.fn.fnamemodify(buf.name, ":p:~:.")
  local parent = vim.fn.fnamemodify(relative, ":h:t")
  local name = vim.fn.fnamemodify(relative, ":t")
  local rest = vim.fn.pathshorten(vim.fn.fnamemodify(relative, ":h:h"), 3)

  local item = {
    name = string.format("%s/%s%s", parent, name, flag),
    rest = rest,
    bufnr = buf.bufnr
  }

  local now = vim.uv.hrtime()
  local timevars = { { "tfocused", nil }, { "tfocus", now }, { "twrite", now } }
  for _, timevar in ipairs(timevars) do
    local var, ref = timevar[1], timevar[2]
    local time = buf.variables["TS_" .. var] or 0
    if time == 0 then
      item[var] = "_"
    else
      if ref then
        time = ref - time
      end
      item[var] = format_time(math.floor(time / 1000000000))
    end
  end

  return item
end

local function make_on_choice(opts)
  local function on_choice(buf, _, key)
    if not buf then return end
    if key == "r" or key == "p" then
      if key == "r" then
        vim.api.nvim_buf_delete(buf.bufnr, {})
      elseif key == "p" then
        local pin_toggle = 1
        if buf.variables.pinned == 1 then
          pin_toggle = 0
        end
        vim.api.nvim_buf_set_var(buf.bufnr, "pinned", pin_toggle)
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

local MRW_opts = {
  prompt = " MRW ",
  format_item = {
    separator = " ",
    columns = { "name", "rest", "twrite" },
    justify = { "r", "l", "r" },
    hl = { "Normal", "Comment", "Character" },
  },
  pipe = {
    filter = function(buf)
      return buf.hidden == 1
    end,
    sort = function(buf1, buf2)
      local l1 = buf1.lastused
      local l2 = buf2.lastused
      local w1 = buf1.variables.TS_twrite
      local w2 = buf2.variables.TS_twrite
      if not w1 and not w2 then
        return l1 > l2
      end
      return (w1 or 0) > (w2 or 0)
    end,
    transform = buftransform,
  },
  keys = {
    accept = { "<CR>", "r", "p" },
  }
}
local MRW_on_choice = make_on_choice(MRW_opts)

local function most_recent_write_select()
  vim.ui.select(
    vim.fn.getbufinfo({ buflisted = 1 }),
    MRW_opts, MRW_on_choice
  )
end

local LFT_opts = {
  pipe = {
    filter = function(buf)
      return
          buf.loaded == 1
          and (buf.variables.TS_tfocused or 0) > 0
    end,
    sort = function(buf1, buf2)
      return buf1.variables.TS_tfocused > buf2.variables.TS_tfocused
    end,
    transform = buftransform,
  },
  prompt = " LFT ",
  format_item = {
    separator = "  ",
    columns = { "name", "rest", "tfocused" },
    justify = { "r", "l", "r" },
    hl = { "Normal", "Comment", "Character" },
  },
  keys = {
    accept = { "<CR>", "r", "p" },
  }
}
local LFT_on_choice = make_on_choice(LFT_opts)

local function largest_focused_time_select()
  vim.ui.select(
    vim.fn.getbufinfo({ buflisted = 1 }),
    LFT_opts, LFT_on_choice
  )
end

local pinned_opts = {
  pipe = {
    filter = function(buf)
      return
          buf.loaded == 1
          and (buf.variables.TS_tfocused or 0) > 0
    end,
    sort = function(buf1, buf2)
      return
          buf1.variables.TS_tfocused > buf2.variables.TS_tfocused
    end,
    transform = buftransform,
  },
  prompt = " LFT ",
  format_item = {
    separator = "  ",
    columns = { "name", "rest", "tfocused" },
    justify = { "r", "l", "r" },
    hl = { "Normal", "Comment", "Character" },
  },
  keys = {
    accept = { "<CR>", "r", "p" },
  }
}
local pinned_on_choice = make_on_choice(pinned_opts)

local function pinned_select()
  vim.ui.select(
    vim.fn.getbufinfo({ buflisted = 1 }),
    pinned_opts, pinned_on_choice
  )
end

return {

  {
    "ivomac/timesaver.nvim",
    dev = true,
    event = { "BufEnter" },
    opts = {},
  },

  {
    "ivomac/floatterm.nvim",
    dev = true,
    dependencies = {
      "akinsho/toggleterm.nvim",
      "ivomac/toothpick.nvim",
    },
    keys = {
      {
        mode = { "x" },
        "<C-h>",
        function()
          require("toggleterm").send_lines_to_terminal("visual_lines", false,
            { args = require("toggleterm.terminal").get_last_focused().id })
        end,
        silent = true,
        noremap = true,
        desc = "Send visual selection to last terminal"
      },
      {
        mode = { "n" },
        "<C-l>",
        function()
          local term = require("floatterm").last_term
          if term then
            term:open()
            term:set_mode("i")
          end
        end,
        silent = true,
        noremap = true,
        desc = "Toggle last term",
      },
      {
        mode = { "n" },
        "<C-j>",
        function() require("floatterm").select() end,
        silent = true,
        noremap = true,
        desc = "Change to terminal",
      },
      {
        mode = { "n" },
        "<C-n>",
        function() require("floatterm").new() end,
        silent = true,
        noremap = true,
        desc = "New terminal",
      },
    },
  },

  {
    "ivomac/toothpick.nvim",
    dev = true,
    cmd = { "Notifications" },
    opts = {
      select = {
        hints = {
          show = false,
        },
        keys = {
          cancel = { "<Esc>", "q" },
        },
      },
      input = {},
      notify = {}
    },
    keys = {
      {
        mode = { "n" },
        "ml",
        most_recent_write_select,
        silent = true,
        noremap = true,
        desc = "Change buffer by most recent write",
      },
      {
        mode = { "n" },
        "mf",
        largest_focused_time_select,
        silent = true,
        noremap = true,
        desc = "Change buffer by focused time",
      },
      {
        mode = { "n" },
        "mp",
        pinned_select,
        silent = true,
        noremap = true,
        desc = "Change to pinned buffer",
      },
    },
  },

  {
    "ivomac/recharge.nvim",
    dev = true,
    dependencies = {
      "ivomac/toothpick.nvim",
      "ivomac/timesaver.nvim",
    },
    opts = {
      folder = vim.fn.expand("~") .. "/Docs/.nvim/sessions",
    },
    cmd = { "Session" },
    keys = {
      { mode = { "n" }, "<leader>sf", function() require("recharge").load() end,   silent = true, noremap = true, desc = "Load" },
      { mode = { "n" }, "<leader>sd", function() require("recharge").delete() end, silent = true, noremap = true, desc = "Delete" },
      { mode = { "n" }, "<leader>ss", function() require("recharge").save() end,   silent = true, noremap = true, desc = "Save" },
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
