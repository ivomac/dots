return {

  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        transparent_mode = true,
      })
    end
  },

  {
    "romainl/vim-cool",
    event = "VeryLazy",
  },

  {
    "monkoose/matchparen.nvim",
    event = "VeryLazy",
    opts = {},
  },

}
