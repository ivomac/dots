vim.opt_local.wrap = true

vim.api.nvim_create_autocmd({ "VimLeavePre" },
  {
    buffer = 0,
    callback = function()
      vim.cmd("LspTexlabCleanArtifacts")
      vim.cmd("LspTexlabCleanAuxiliary")
    end,
  }
)

vim.b[0].build_on_save = false

vim.api.nvim_create_autocmd({ "BufWritePost" },
  {
    buffer = 0,
    callback = function(ev)
      if vim.b[ev.buf].build_on_save then
        vim.cmd("LspTexlabBuild")
      end
    end,
  }
)

function ToggleBuildOnSave()
  vim.b[0].build_on_save = not vim.b[0].build_on_save
  if vim.b[0].build_on_save then
    print("Building on save.")
    vim.cmd("LspTexlabBuild")
  else
    print("Stopped building on save.")
  end
end

vim.keymap.set("n", "<leader>M", ToggleBuildOnSave, { buffer = 0, desc = "Toggle build on save" })
vim.keymap.set("n", "gae", "<cmd>LspTexlabChangeEnvironment<CR>", { buffer = 0, desc = "Change environment" })
vim.keymap.set("n", "<S-CR>", "<cmd>LspTexlabForward<CR>", { buffer = 0, desc = "Go to line in PDF" })
