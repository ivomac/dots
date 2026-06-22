return {

  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      default = true,
      strict = true,
    },
  },



  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = {
        enable = true,
        priority = 0,
        use_treesitter = false,
        chars = { "│", "╎", "┆", "┊" },
        ahead_lines = 0,
        exclude_filetypes = {
          "help",
        },
      },
    }
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      icons = { mappings = false },
      spec = {
        { "<leader>", group = "Leader" },
        { "<leader>a", group = "Actions" },
        { "<leader>j", group = "Snippets" },
        { "<leader>w", group = "Workdir/Buffer/OS Cmds" },
        { "<leader>f", group = "FZF" },
        { "<leader>g", group = "FZF Lsp" },
        { "<leader>ga", group = "FZF Lsp Actions" },
        { "<leader>gs", group = "FZF Lsp Symbols" },
        { "<leader>s", group = "Session" },
        { "<leader>t", group = "Test" },
        { "[", group = "Previous…" },
        { "]", group = "Next…" },
        { "g", group = "GO!" },
        { "ga", group = "LSP Actions" },
        { "gh", group = "Hunk/Gitsigns" },
        { "gs", group = "LSP Symbols" },
        { "gsl", group = "Lower" },
        { "gsu", group = "Upper" },
        { "z", group = "Fold/Spelling" },
      }
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    opts = {
      options = {
        component_separators = "",
        section_separators = "",
        theme = "gruvbox",
        globalstatus = true,
        refresh = {
          always_divide_middle = false,
          statusline = 1000,
          tabline = 999999,
          winbar = 999999
        }
      },
      sections = {
        lualine_a = {},
        lualine_b = {
          {
            function()
              local session = vim.g.session_info
              if session then
                return string.format("[%s]", session.name)
              end
              return ""
            end,
            draw_empty = false,
            padding = { left = 1, right = 0 }
          },
          {
            "filename",
            path = 4,
            shorting_target = 32,
            padding = { left = 1, right = 1 }
          },
          {
            "filetype",
            icon_only = true,
            colored = false,
            padding = {
              left = 0,
              right = 0,
            },
          },
        },
        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
            },
            padding = { left = 1, right = 1 },
          },
        },
        lualine_x = {
          {
            "diff",
            symbols = { added = " ", modified = "󰦓 ", removed = " " },
            colored = false,
            padding = { left = 1, right = 1 },
          },
        },
        lualine_y = {
          {
            "branch",
            icon = "",
            draw_empty = false,
            padding = {
              left = 1,
              right = 0,
            },
          },
          {
            'lsp_status',
            symbols = {
              spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
              done = '✓',
              separator = '·',
            },
            icon = "",
            padding = { left = 1, right = 0 },
          },
          { "filesize", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 1, right = 1 } },
        },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    },
  },

  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
    config = function()
      require("statuscol").setup({
        segments = {
          {
            sign = {
              text = { ".*" },
              maxwidth = 1,
              colwidth = 1,
              auto = false,
              wrap = false,
            },
          },
        }
      })
    end,
  },

}
