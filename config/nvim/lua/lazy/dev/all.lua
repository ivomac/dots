-- format time in "3h42m10s" format
local function format_time(time)
  time = math.floor(time)
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
  local relpath = vim.fn.fnamemodify(buf.name, ":p:~:.")

  local flag = ""
  if buf.changed == 1 then
    flag = "+"
  end

  local now = vim.uv.hrtime()

  local tfocused = "_"
  if buf.variables["TS_tfocused"] then
    tfocused = format_time(buf.variables["TS_tfocused"] / 1000000000)
  end

  local twrite = "_"
  if buf.variables["TS_twrite"] then
    twrite = format_time((now - buf.variables["TS_twrite"]) / 1000000000)
  end

  return {
    bufnr = buf.bufnr,
    filename = string.format(
      "%s/%s%s",
      vim.fn.fnamemodify(relpath, ":h:t"),
      vim.fn.fnamemodify(relpath, ":t"),
      flag
    ),
    shortpath = vim.fn.pathshorten(vim.fn.fnamemodify(relpath, ":h:h"), 3),
    lastused = format_time(os.time() - buf.lastused),
    tfocused = tfocused,
    twrite = twrite,
  }
end

local function make_on_choice(opts)
  local function on_choice(buf, _, key)
    if not buf then return end
    if key == "r" then
      vim.api.nvim_buf_delete(buf.bufnr, {})

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

local LUB_opts = {
  prompt = " LUB ",
  format_item = {
    separator = " ",
    columns = { "filename", "shortpath", "lastused" },
    justify = { "r", "l", "r" },
    hl = { "Normal", "Comment", "Character" },
  },
  pipe = {
    filter = function(buf)
      -- exclude visible buffers
      return buf.hidden == 1
    end,
    sort = function(buf1, buf2)
      -- sort by lastused timestamp
      return (buf1.lastused or 0) > (buf2.lastused or 0)
    end,
    transform = buftransform,
  },
  keys = {
    accept = { "<CR>", "r" },
  }
}

local LUB_on_choice = make_on_choice(LUB_opts)

local function last_used_buffer_select()
  vim.ui.select(vim.fn.getbufinfo({ buflisted = 1 }), LUB_opts, LUB_on_choice)
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
    accept = { "<CR>", "r" },
  }
}

local MRW_on_choice = make_on_choice(MRW_opts)

local function most_recent_write_select()
  vim.ui.select(vim.fn.getbufinfo({ buflisted = 1 }), MRW_opts, MRW_on_choice)
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
    accept = { "<CR>", "r" },
  }
}

local LFT_on_choice = make_on_choice(LFT_opts)

local function largest_focused_time_select()
  vim.ui.select(vim.fn.getbufinfo({ buflisted = 1 }), LFT_opts, LFT_on_choice)
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
        "<C-k>",
        function() require("floatterm").select() end,
        silent = true,
        noremap = true,
        desc = "Select terminal",
      },
      {
        mode = { "n" },
        "<C-j>",
        function() require("floatterm").open() end,
        silent = true,
        noremap = true,
        desc = "Open terminal",
      },
    },
  },



  {
    "ivomac/toothpick.nvim",
    opts = {
      select = {},
      input = {},
      notify = {}
    },
    cmd = { "Notifications" },
    keys = {
      {
        mode = { "n" },
        "ml",
        last_used_buffer_select,
        silent = true,
        noremap = true,
        desc = "List buffers by order of access",
      },
      {
        mode = { "n" },
        "mw",
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
      }
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
