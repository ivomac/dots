vim.treesitter.language.add("zsh", "bash")
vim.treesitter.language.add("sh", "bash")

return {

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf = args.buf
          local max_filesize = 400 * 1024
          local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
          if stats and stats.size < max_filesize then
            pcall(vim.treesitter.start, buf)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local ensureInstalled = { "bash", "lua", "python" }
      local alreadyInstalled = require('nvim-treesitter.config').get_installed()
      local parsersToInstall = vim.iter(ensureInstalled)
          :filter(function(parser)
            return not vim.tbl_contains(alreadyInstalled, parser)
          end)
          :totable()
      require('nvim-treesitter').install(parsersToInstall)
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
    branch = "main",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
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
        },
        move = {
          enable = true,
          set_jumps = true,
        },
      })
      local ts_select = require("nvim-treesitter-textobjects.select")
      local ts_move = require("nvim-treesitter-textobjects.move")

      local select_maps = {
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
        ["a="] = "@assignment.outer",
        ["i="] = "@assignment.inner",
      }

      for lhs, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          ts_select.select_textobject(query, "textobjects")
        end)
      end

      local move_configs = {
        { fn = ts_move.goto_next_start,     keys = { ["]a"] = "@parameter.outer", ["]c"] = "@class.outer", ["]f"] = "@function.outer", ["]i"] = "@conditional.outer", ["]l"] = "@loop.outer", ["]o"] = "@comment.outer", ["]r"] = "@return.outer", ["]="] = "@assignment.outer" } },
        { fn = ts_move.goto_next_end,       keys = { ["]C"] = "@class.outer", ["]F"] = "@function.outer", ["]I"] = "@conditional.outer", ["]R"] = "@return.outer" } },
        { fn = ts_move.goto_previous_start, keys = { ["[a"] = "@parameter.outer", ["[c"] = "@class.outer", ["[f"] = "@function.outer", ["[i"] = "@conditional.outer", ["[l"] = "@loop.outer", ["[o"] = "@comment.outer", ["[r"] = "@return.outer", ["[="] = "@assignment.outer" } },
        { fn = ts_move.goto_previous_end,   keys = { ["[C"] = "@class.outer", ["[F"] = "@function.outer", ["[I"] = "@conditional.outer", ["[R"] = "@return.outer" } },
      }

      for _, config in ipairs(move_configs) do
        for lhs, query in pairs(config.keys) do
          vim.keymap.set("n", lhs, function()
            config.fn(query, "textobjects")
          end)
        end
      end
    end,
  },
}
