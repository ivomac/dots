vim.b.did_ftplugin = 1

vim.opt_local.commentstring = "% %s"
vim.opt_local.comments = ":%"

vim.opt_local.wrap = true

vim.api.nvim_create_autocmd({ "BufUnload" },
  {
    group = vim.api.nvim_create_augroup("LSP_TEX_CLEAN", { clear = true }),
    buffer = 0,
    callback = function(ev)
      local clients = vim.lsp.get_clients({ buf = ev.buf })
      for _, client in ipairs(clients) do
        if client.name == "texlab" then
          vim.api.nvim_buf_call(ev.buf, vim.cmd.LspTexlabCleanAuxiliary)
        end
      end
    end,
  }
)

local function toggle_build_on_save()
  local build_aucmd = vim.b[0].build_aucmd
  if build_aucmd then
    vim.api.nvim_del_autocmd(build_aucmd)
    vim.api.nvim_buf_del_var(0, "build_aucmd")
    vim.notify("Stopped building on save", vim.log.levels.INFO)
  else
    vim.notify("Building on save", vim.log.levels.INFO)
    build_aucmd = vim.api.nvim_create_autocmd({ "BufWritePost" },
      {
        buffer = 0,
        callback = function(_) vim.cmd.LspTexlabBuild() end,
      }
    )
    vim.api.nvim_buf_set_var(0, "build_aucmd", build_aucmd)
    vim.cmd.LspTexlabBuild()
  end
end

vim.keymap.set("n", "<leader>m", toggle_build_on_save,
  { noremap = true, buffer = 0, desc = "Toggle build on save" })
vim.keymap.set("n", "gae", "<cmd>LspTexlabChangeEnvironment<CR>",
  { noremap = true, buffer = 0, desc = "Change environment" })
vim.keymap.set("n", "<S-CR>", "<cmd>LspTexlabForward<CR>",
  { noremap = true, buffer = 0, desc = "Go to line in PDF" })
