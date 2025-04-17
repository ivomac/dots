return {
  {
    'Wansmer/treesj',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { use_default_keymaps = false },
    keys = {
      { "<leader>aj", function() require('treesj').toggle({ split = { recursive = true } }) end, mode = { "n", "x" }, desc = "Join/Break" },
    }
  },
  { "tpope/vim-repeat" },

  { "kana/vim-operator-user" },
  {
    "thinca/vim-visualstar",
    dependencies = { "kana/vim-operator-user" },
  },

  {
    "gbprod/substitute.nvim",
    opts = {
      on_substitute = nil,
      yank_substituted_text = false,
      preserve_cursor_position = false,
      modifiers = nil,
      highlight_substituted_text = {
        enabled = true,
        timer = 500,
      },
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        subject = nil,
        range = nil,
        suffix = "",
        auto_apply = false,
        cursor_position = "end",
      },
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
        preserve_cursor_position = false,
      },
    },
    keys = {
      {
        "-",
        function()
          local ops = {
            ["d"] = true,
            ["D"] = true,
            ["c"] = true,
            ["C"] = true,
            ["s"] = true,
            ["S"] = true,
            ["r"] = true,
            ["R"] = true,
            ["x"] = true,
            ["X"] = true,
          }
          local char = vim.fn.getcharstr()
          if char == "y" then
            vim.api.nvim_feedkeys('"+y', "nt", false)
          elseif ops[char] then
            vim.api.nvim_feedkeys('"_' .. char, "nt", false)
          else
            require('substitute').operator({ motion = char })
          end
        end,
        mode = "n",
        desc = "Substitute",
      },
      {
        "-",
        function()
          local char = vim.fn.getcharstr()
          if char == "y" then
            vim.api.nvim_feedkeys('"+y', "nt", false)
          elseif char == "p" then
            vim.api.nvim_feedkeys('"_dP', "nt", false)
          end
        end,
        mode = "x",
        desc = "Substitute",
      },
      { "cx", function() require('substitute.exchange').operator() end, mode = { "n" }, desc = "Exchange" },
      { "X",  function() require('substitute.exchange').visual() end,   mode = { "x" }, desc = "Exchange" },

    },
  },

  {
    "kylechui/nvim-surround",
    opts = {
      keymaps = {
        insert = false,
        insert_line = false,
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    keys = {
      { mode = { "n" }, "ys" },
      { mode = { "n" }, "yS" },
      { mode = { "n" }, "cs" },
      { mode = { "n" }, "cS" },
      { mode = { "n" }, "ds" },
      { mode = { "x" }, "S" },
      { mode = { "x" }, "gS" },
      { mode = { "i" }, "<C-g>s" },
      { mode = { "i" }, "<C-g>S" },
    },
  },

}
