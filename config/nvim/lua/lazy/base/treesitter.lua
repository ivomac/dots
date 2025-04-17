return {

  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      vim.treesitter.language.register("bash", "zsh")
      vim.treesitter.language.register("bash", "sh")

      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "lua", "python" },
        auto_install = false,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 400 * 1024 -- 400 KB
            local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
            if stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        incremental_selection = {
          enable = false,
        },
        matchup = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            selection_modes = {
              ["@function.outer"]    = "V",
              ["@conditional.outer"] = "V",
              ["@class.outer"]       = "V",
              ["@loop.outer"]        = "V",
              ["@comment.outer"]     = "V",
            },
            keymaps = {
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ar"] = "@return.outer",
              ["ir"] = "@return.inner",
              ["ae"] = "@assignment.outer",
              ["ie"] = "@assignment.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]a"] = "@parameter.outer",
              ["]c"] = "@class.outer",
              ["]f"] = "@function.outer",
              ["]i"] = "@conditional.outer",
              ["]l"] = "@loop.outer",
              ["]o"] = "@comment.outer",
              ["]r"] = "@return.outer",
              ["]e"] = "@assignment.outer",
            },
            goto_next_end = {
              ["]C"] = "@class.outer",
              ["]F"] = "@function.outer",
              ["]I"] = "@conditional.outer",
              ["]R"] = "@return.outer",
            },
            goto_previous_start = {
              ["[a"] = "@parameter.outer",
              ["[c"] = "@class.outer",
              ["[f"] = "@function.outer",
              ["[i"] = "@conditional.outer",
              ["[l"] = "@loop.outer",
              ["[o"] = "@comment.outer",
              ["[r"] = "@return.outer",
              ["[e"] = "@assignment.outer",
            },
            goto_previous_end = {
              ["[C"] = "@class.outer",
              ["[F"] = "@function.outer",
              ["[I"] = "@conditional.outer",
              ["[R"] = "@return.outer",
            },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      multiwindow = false,
      max_lines = 3,
      min_window_height = 20,
      line_numbers = false,
      multiline_threshold = 1,
      trim_scope = 'outer',
      mode = 'cursor',
      zindex = 10,
    }
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
