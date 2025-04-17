local fzf_fd_command = os.getenv("FZF_NAV_FD_COMMAND") or "fd "
local fzf_rg_command = os.getenv("FZF_NAV_RG_COMMAND") or "rg "

-- remove "fd" and "rg" from beginning of the commands

fzf_fd_command = fzf_fd_command:gsub("^fd ", "") .. " --type f"
fzf_rg_command = fzf_rg_command:gsub("^rg ", "") .. " --files"

return {

  {
    "ibhagwan/fzf-lua",
    cmd = { "FzfLua" },
    opts = {
      files = {
        fd_opts = fzf_fd_command,
        rg_opts = fzf_rg_command,
      },
      winopts = {
        width = 0.95,
        height = 0.95,
        row = 1.01,
        backdrop = 100,
        preview = {
          wrap = true,
          delay = 100,
          winopts = {
            number         = false,
            relativenumber = false,
            cursorline     = true,
            cursorlineopt  = "both",
            cursorcolumn   = false,
            signcolumn     = "yes:1",
            list           = false,
            foldenable     = false,
            foldmethod     = "manual",
          },
        },
      },
    },
    keys = {
      { mode = { "n" }, "<leader><leader>", function() require("fzf-lua").resume() end,                     silent = true, desc = "Last FZF" },

      { mode = { "n" }, "<leader>fb",       function() require("fzf-lua").buffers() end,                    silent = true, desc = "Buffers" },
      { mode = { "n" }, "<leader>fa",       function() require("fzf-lua").files() end,                      silent = true, desc = "All Files" },
      { mode = { "n" }, "<leader>fq",       function() require("fzf-lua").quickfix() end,                   silent = true, desc = "Quickfix" },
      { mode = { "n" }, "<leader>fQ",       function() require("fzf-lua").quickfix_stack() end,             silent = true, desc = "Quickfix stack" },

      { mode = { "n" }, "<leader>fS",       function() require("fzf-lua").grep() end,                       silent = true, desc = "Search" },
      { mode = { "x" }, "<leader>fs",       function() require("fzf-lua").grep_visual() end,                silent = true, desc = "Search visual" },
      { mode = { "n" }, "<leader>fs",       function() require("fzf-lua").live_grep_native() end,           silent = true, desc = "Search Live" },

      { mode = { "n" }, "<leader>gc",       function() require("fzf-lua").git_commits() end,                silent = true, desc = "Git commits" },

      { mode = { "n" }, "<leader>gad",      function() require("fzf-lua").lsp_workspace_diagnostics() end,  silent = true, desc = "Diagnostics" },
      { mode = { "n" }, "<leader>gal",      function() require("fzf-lua").lsp_code_actions() end,           silent = true, desc = "Action list" },

      { mode = { "n" }, "<leader>gsd",      function() require("fzf-lua").lsp_definitions() end,            silent = true, desc = "Symb definitions" },
      { mode = { "n" }, "<leader>gsD",      function() require("fzf-lua").lsp_declarations() end,           silent = true, desc = "Symb declarations" },
      { mode = { "n" }, "<leader>gst",      function() require("fzf-lua").lsp_typedefs() end,               silent = true, desc = "Symb type" },
      { mode = { "n" }, "<leader>gsi",      function() require("fzf-lua").lsp_implementations() end,        silent = true, desc = "Symb implementations" },
      { mode = { "n" }, "<leader>gsr",      function() require("fzf-lua").lsp_references() end,             silent = true, desc = "Symb references" },

      { mode = { "n" }, "<leader>gss",      function() require("fzf-lua").lsp_live_workspace_symbols() end, silent = true, desc = "All Symbs" },

      { mode = { "n" }, "<leader>gsuc",     function() require("fzf-lua").lsp_outgoing_calls() end,         silent = true, desc = "Symb calling" },
      { mode = { "n" }, "<leader>gslc",     function() require("fzf-lua").lsp_incoming_calls() end,         silent = true, desc = "Symb called by" },

      { mode = { "n" }, "<leader>fK",       function() require("fzf-lua").helptags() end,                   silent = true, desc = "Help Tags" },
      { mode = { "n" }, "<leader>fu",       function() require("fzf-lua").changes() end,                    silent = true, desc = "Changes" },

      { mode = { "n" }, "<leader>db",       function() require("fzf-lua").dap_breakpoints() end,            silent = true, desc = "List Breakpoints" },
      { mode = { "n" }, "<leader>dv",       function() require("fzf-lua").dap_variables() end,              silent = true, desc = "List Variables" },
    },

  },

}
