
local function generate_cmp_item(snip)
	return {
		label = snip.label or snip.trigger,
		word = snip.trigger,
		insertText = snip.body,
		kind = vim.lsp.protocol.CompletionItemKind.Snippet,
		insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
	}
end


local snippets_dir = vim.fn.stdpath("config") .. "/lua/snippets"
local snippet_files = vim.fn.readdir(snippets_dir)


local snippets = {}
for _, file in ipairs(snippet_files) do
	local ft = file:match("^(.+)%.lua$")
	local ok, snips = pcall(require, "snippets." .. ft)
	if ok then
		snippets[ft] = vim.list_slice(vim.tbl_map(generate_cmp_item, snips))
	else
		vim.notify("Failed to load snippets for " .. ft .. ": " .. snips, vim.log.levels.ERROR)
	end
end

for k, _ in pairs(snippets) do
	if k ~= "all" then
		vim.list_extend(snippets[k], snippets["all"])
	end
end

local cache = {}

local cmp_source = {}
function cmp_source.complete(_, _, callback)
	local bufnr = vim.api.nvim_get_current_buf()
	if not cache[bufnr] then
		local ft = vim.bo[bufnr].filetype
		cache[bufnr] = snippets[ft] or snippets["all"]
	end
	callback(cache[bufnr])
end


require("cmp").register_source("local_snips", cmp_source)
