LOADED_CLIENTS = {}

SERVER_CAPABILITIES = {
	ruff = {
		hoverProvider = false,
	},
	jedi_language_server = {
		referencesProvider = false,
		renameProvider = false,
	},
	pyright = {
		codeActionProvider = false,
		completionProvider = false,
		declarationProvider = false,
		definitionProvider = false,
		documentHighlightProvider = false,
		documentSymbolProvider = false,
		executeCommandProvider = false,
		hoverProvider = false,
		signatureHelpProvider = false,
		typeDefinitionProvider = false,
		workspaceSymbolProvider = false
	},
}

local fts = {
	"python", "vim", "julia",
	"c", "cpp", "cuda", "zig", "zir",
	"objc", "objcpp", "proto", "rust",
	"go", "gomod", "gowork", "gotmpl",
	"sh", "bash", "zsh",
	"css", "scss", "less", "html", "templ",
	"javascript", "typescript",
	"jq", "json", "jsonc", "lua", "yaml", "sql", "mysql",
	"typst", "markdown", "bib", "tex",
	"plaintex", "matlab",
}

return {

	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		ft = fts,
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

			capabilities.textDocument.completion = cmp_capabilities.textDocument.completion
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true
			}

			local servers = { "clangd", "html", "julials", "lua_ls",
				"marksman", "matlab_ls", "sqls", "ts_ls", "cssls",
				"pyright", "jedi_language_server", "ruff",
				"vimls", "yamlls", "zls",
			}
			for _, lsp in ipairs(servers) do
				lspconfig[lsp].setup({
					capabilities = capabilities,
				})
			end

			lspconfig.gopls.setup({
				formatting = {
					gofumpt = true,
				}
			})

			lspconfig.tinymist.setup {
				settings = {
					formatterMode = "typstyle",
					exportPdf = "onType",
					semanticTokens = "disable"
				}
			}

			lspconfig.bashls.setup({
				filetypes = { "sh", "bash", "zsh", "csh" },
			})

			lspconfig.jsonls.setup({
				init_options = {
					provideFormatter = true,
				}
			})

			lspconfig.rust_analyzer.setup({
				settings = {
					["rust-analyzer"] = {
						diagnostics = {
							enable = true,
						}
					}
				}
			})

			local texlab_config = {
				settings = {
					texlab = {
						auxDirectory = ".",
						bibtexFormatter = "texlab",
						build = {
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
							executable = "latexmk",
							forwardSearchAfter = false,
							onSave = true
						},
						chktex = {
							onEdit = false,
							onOpenAndSave = true,
						},
						diagnosticsDelay = 1000,
						formatterLineLength = 80,
						latexFormatter = "latexindent",
						latexindent = {
							modifyLineBreaks = false
						}
					}
				}
			}
			lspconfig.texlab.setup(texlab_config)

			local function trigger_workspace_diagnostics(client, bufnr, workspace_files)
				if vim.tbl_contains(LOADED_CLIENTS, client.id) then
					return
				end
				table.insert(LOADED_CLIENTS, client.id)

				if not vim.tbl_get(client.server_capabilities, 'textDocumentSync', 'openClose') then
					return
				end

				for _, path in ipairs(workspace_files) do
					if path == vim.api.nvim_buf_get_name(bufnr) then
						return
					end

					local filetype = vim.filetype.match({ filename = path })

					if not vim.tbl_contains(client.config.filetypes, filetype) then
						return
					end

					local params = {
						textDocument = {
							uri = vim.uri_from_fname(path),
							version = 0,
							text = vim.fn.join(vim.fn.readfile(path), "\n"),
							languageId = filetype
						}
					}
					client.notify('textDocument/didOpen', params)
				end
			end


			vim.api.nvim_create_user_command("LspCapabilities",
				function()
					for _, client in ipairs(vim.lsp.get_clients()) do
						vim.print(vim.inspect(client.name))
						vim.print(vim.inspect(client.server_capabilities))
					end
				end,
				{}
			)

			function OpenDiagnosticIfNoFloat()
				for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
					if vim.api.nvim_win_get_config(winid).zindex then
						return
					end
				end
				vim.diagnostic.open_float()
			end

			local group = vim.api.nvim_create_augroup("LSP_DIAGNOSTICS", { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold" }, {
				pattern = "*",
				callback = OpenDiagnosticIfNoFloat,
				group = group,
			})

			local augroup = vim.api.nvim_create_augroup("LSP_ATTACH", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf

					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client == nil then return end

					local local_capabilities = client.server_capabilities
					if local_capabilities == nil then return end

					client.server_capabilities.semanticTokensProvider = nil

					if local_capabilities.diagnosticProvider then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
								if diagnostics and #diagnostics > 0 then
									return
								end
								vim.lsp.buf.format({ async = false })
							end
						})
					end

					if SERVER_CAPABILITIES[client.name] then
						for local_capability, val in pairs(SERVER_CAPABILITIES[client.name]) do
							client.server_capabilities[local_capability] = val
						end
					end

					trigger_workspace_diagnostics(client, bufnr, ReadableGitFiles())
				end,
			})

			vim.diagnostic.config({
				underline = true,
				virtual_text = false,
				virtual_lines = false,
				signs = true,
				severity_sort = true,
				update_in_insert = false,
				float = {
					focusable = false,
					severity_sort = true,
					source = true,
					header = "",
					scope = "cursor",
				},
			})

			vim.keymap.set({ "n", "x" }, "gad", vim.diagnostic.setqflist, { desc = "Diagnostics" })
			vim.keymap.set({ "n", "x" }, "gal", vim.lsp.buf.code_action, { desc = "Action list" })
			vim.keymap.set({ "n", "x" }, "gar", vim.lsp.buf.rename, { desc = "Rename" })
			vim.keymap.set({ "n", "x" }, "gaf", vim.lsp.buf.format, { desc = "Format" })

			vim.keymap.set({ "n", "x" }, "gsd", vim.lsp.buf.definition, { desc = "Symb definition" })
			vim.keymap.set({ "n", "x" }, "gsD", vim.lsp.buf.declaration, { desc = "Symb declaration" })
			vim.keymap.set({ "n", "x" }, "gst", vim.lsp.buf.type_definition, { desc = "Symb type" })
			vim.keymap.set({ "n", "x" }, "gsi", vim.lsp.buf.implementation, { desc = "Symb implementations" })
			vim.keymap.set({ "n", "x" }, "gsr", vim.lsp.buf.references, { desc = "Symb references" })

			vim.keymap.set({ "n", "x" }, "gsut", function() vim.lsp.buf.typehierarchy("supertypes") end,
				{ desc = "Symb upper types" })
			vim.keymap.set({ "n", "x" }, "gslt", function() vim.lsp.buf.typehierarchy("subtypes") end,
				{ desc = "Symb lower types" })

			vim.keymap.set({ "n", "x" }, "gsuc", vim.lsp.buf.outgoing_calls, { desc = "Symb calling" })
			vim.keymap.set({ "n", "x" }, "gslc", vim.lsp.buf.incoming_calls, { desc = "Symb called by" })
		end
	},
	{
		"hedyhli/outline.nvim",
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "gss", function() require("outline").toggle() end, desc = "All Symbs" },
		},
		opts = {
			outline_window = {
				position = "left",
				width = 30,
				auto_close = true,
				auto_jump = true,
				jump_highlight_duration = 0,
			},
			symbols = {
				icon_source = "lspkind",
			},
		},
	},
}
