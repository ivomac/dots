local M = {}

function M.generate_cmp_item(snip)
  return {
    label = snip.label or snip.trigger,
    word = snip.trigger,
    insertText = snip.body,
    kind = vim.lsp.protocol.CompletionItemKind.Snippet,
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
  }
end

function M.setup(opts)
  local snippets = {}
  for _, root_folder in ipairs(opts.folders) do
    root_folder = vim.fn.fnamemodify(root_folder, ":p")
    for _, file in ipairs(vim.fn.globpath(root_folder, "**/*.lua", false, true, false)) do
      local relative_path = file:sub(#root_folder + 1)
      local ft = relative_path:match("^([^/]+)/") or relative_path:match("^(.+)%.lua$")

      local snips = vim.tbl_map(M.generate_cmp_item, dofile(file))
      snippets[ft] = vim.list_extend(snippets[ft] or {}, snips)
    end
  end

  if snippets.all then
    for k, ftsnips in pairs(snippets) do
      if k ~= "all" then
        vim.list_extend(ftsnips, snippets.all)
      end
    end
  end

  local cache = {}
  local cmp_source = {}

  function cmp_source.complete(_, _, callback)
    local bufnr = vim.api.nvim_get_current_buf()
    if not cache[bufnr] then
      local ft = vim.bo[bufnr].filetype
      cache[bufnr] = snippets[ft] or snippets.all or {}
    end
    callback(cache[bufnr])
  end

  require("cmp").register_source("neosnip", cmp_source)
end

return M
