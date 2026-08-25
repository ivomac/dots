vim.treesitter.language.add("zsh", "bash")
vim.treesitter.language.add("sh", "bash")

return {
  {
    "romus204/tree-sitter-manager.nvim",
    lazy = false,
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "go",
          "html",
          "javascript",
          "json",
          "latex",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "rust",
          "toml",
          "typescript",
          "typst",
          "vim",
          "vimdoc",
          "yaml",
        },
        auto_install = true,
        highlight = true,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
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
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
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
        ["aa"] = { query = "@parameter.outer", desc = "An argument" },
        ["ia"] = { query = "@parameter.inner", desc = "In argument" },
        ["ao"] = { query = "@comment.outer", desc = "A comment" },
        ["io"] = { query = "@comment.inner", desc = "In comment" },
        ["ac"] = { query = "@class.outer", desc = "A class" },
        ["ic"] = { query = "@class.inner", desc = "In class" },
        ["af"] = { query = "@function.outer", desc = "A function" },
        ["if"] = { query = "@function.inner", desc = "In function" },
        ["ai"] = { query = "@conditional.outer", desc = "A conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "In conditional" },
        ["al"] = { query = "@loop.outer", desc = "A loop" },
        ["il"] = { query = "@loop.inner", desc = "In loop" },
        ["ar"] = { query = "@return.outer", desc = "A return" },
        ["ir"] = { query = "@return.inner", desc = "In return" },
        ["a="] = { query = "@assignment.outer", desc = "An assignment" },
        ["i="] = { query = "@assignment.inner", desc = "In assignment" },
      }

      for lhs, map in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          ts_select.select_textobject(map.query, "textobjects")
        end, { desc = map.desc })
      end

      local textobject_names = {
        ["@parameter.outer"] = "argument",
        ["@class.outer"] = "class",
        ["@function.outer"] = "function",
        ["@conditional.outer"] = "conditional",
        ["@loop.outer"] = "loop",
        ["@comment.outer"] = "comment",
        ["@return.outer"] = "return",
        ["@assignment.outer"] = "assignment",
      }
      local move_configs = {
        { label = "Next start", fn = ts_move.goto_next_start, keys = { ["]a"] = "@parameter.outer", ["]c"] = "@class.outer", ["]f"] = "@function.outer", ["]i"] = "@conditional.outer", ["]l"] = "@loop.outer", ["]o"] = "@comment.outer", ["]r"] = "@return.outer", ["]="] = "@assignment.outer" } },
        { label = "Next end", fn = ts_move.goto_next_end, keys = { ["]C"] = "@class.outer", ["]F"] = "@function.outer", ["]I"] = "@conditional.outer", ["]R"] = "@return.outer" } },
        { label = "Previous start", fn = ts_move.goto_previous_start, keys = { ["[a"] = "@parameter.outer", ["[c"] = "@class.outer", ["[f"] = "@function.outer", ["[i"] = "@conditional.outer", ["[l"] = "@loop.outer", ["[o"] = "@comment.outer", ["[r"] = "@return.outer", ["[="] = "@assignment.outer" } },
        { label = "Previous end", fn = ts_move.goto_previous_end, keys = { ["[C"] = "@class.outer", ["[F"] = "@function.outer", ["[I"] = "@conditional.outer", ["[R"] = "@return.outer" } },
      }

      for _, config in ipairs(move_configs) do
        for lhs, query in pairs(config.keys) do
          vim.keymap.set("n", lhs, function()
            config.fn(query, "textobjects")
          end, { desc = config.label .. " " .. textobject_names[query] })
        end
      end
    end,
  },
}
