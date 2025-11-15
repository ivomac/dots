local function create_graph()
  local dot_file = vim.fn.expand("%:t:r") .. ".dot"
  local png_file = vim.fn.expand("%:t:r") .. ".png"
  local cmd = { "dot", "-Tpng", dot_file, "-o", png_file }
  vim.fn.jobstart(cmd, { type = "pty" })
end

local function open_graph()
  local png_file = vim.fn.expand("%:t:r") .. ".png"
  local cmd = { "xdg-open", png_file }
  vim.fn.jobstart(cmd, { type = "pty" })
end

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
        callback = create_graph
      }
    )
    vim.api.nvim_buf_set_var(0, "build_aucmd", build_aucmd)
    create_graph()
  end
end

vim.keymap.set("n", "<leader>m", toggle_build_on_save,
  { noremap = true, buffer = 0, desc = "Toggle build on save" })

vim.keymap.set("n", "<S-CR>", open_graph,
  { noremap = true, buffer = 0, desc = "Open created image" })
