local M = {}

function M.setup(opts)
  opts = vim.tbl_deep_extend("force",
    {
      select = {},
      input = {}
    },
    opts
  )

  vim.api.nvim_set_hl(0, "SnippetTabstop", {})

  for key, sub_opts in pairs(opts) do
    require("toothpick." .. key).setup(sub_opts)
  end
end

return M
