vim.b.did_ftplugin = 1

vim.opt_local.commentstring = "% %s"
vim.opt_local.comments = ":%"

vim.opt_local.wrap = true
vim.b[0].build_on_save = false

local group = vim.api.nvim_create_augroup("LSP_TEX", { clear = true })


vim.api.nvim_create_autocmd({ "BufUnload" },
  {
    group = group,
    buffer = 0,
    callback = function(ev)
      local file = io.open(os.getenv("HOME") .. "/test.txt", "w")
      if file then
        file:write(vim.inspect(ev))
        file:close()
      end

      local clients = vim.lsp.get_clients({ buf = ev.buf })

      for _, client in ipairs(clients) do
        if client.name == "texlab" then
          -- vim.cmd("LspTexlabCleanArtifacts")
          vim.cmd("LspTexlabCleanAuxiliary")
        end
      end
    end,
  }
)

vim.api.nvim_create_autocmd({ "BufWritePost" },
  {
    group = group,
    buffer = 0,
    callback = function(ev)
      if vim.b[ev.buf].build_on_save then
        vim.cmd("LspTexlabBuild")
      end
    end,
  }
)

local function toggle_build_on_save()
  vim.b[0].build_on_save = not vim.b[0].build_on_save
  if vim.b[0].build_on_save then
    vim.notify("Building on save.", vim.log.levels.INFO)
    vim.cmd("LspTexlabBuild")
  else
    vim.notify("Stopped building on save.", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>M", toggle_build_on_save,
  { noremap = true, buffer = 0, desc = "Toggle build on save" })
vim.keymap.set("n", "gae", "<cmd>LspTexlabChangeEnvironment<CR>",
  { noremap = true, buffer = 0, desc = "Change environment" })
vim.keymap.set("n", "<S-CR>", "<cmd>LspTexlabForward<CR>",
  { noremap = true, buffer = 0, desc = "Go to line in PDF" })
