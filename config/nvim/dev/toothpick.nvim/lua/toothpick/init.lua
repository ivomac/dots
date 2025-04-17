local M = {}

function M.setup(opts)
  for key, sub_opts in pairs(opts) do
    require("toothpick." .. key).setup(sub_opts)
  end
end

return M
