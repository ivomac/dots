LOADED_CLIENTS = {}

return {

  {
    "neovim/nvim-lspconfig",
    ft = {
      "bash",
      "c",
      "cpp",
      "csh",
      "css",
      "go",
      "h",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "python",
      "rust",
      "sh",
      "tex",
      "toml",
      "typescript",
      "typst",
      "vim",
      "yaml",
      "zsh",
    },
    dependencies = {
      "ivomac/toothpick.nvim",
      "ivomac/workout.nvim",
    },
    config = function()
      vim.lsp.set_log_level("debug")

      vim.lsp.config["marksman"] = {
        root_markers = {},
      }

      vim.lsp.config["pyright"] = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "workspace",
              diagnosticMode = "openFilesOnly",
              autoSearchPaths = true,
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
              diagnosticSeverityOverrides = {
                reportUnusedImport = "none",
                reportUnusedVariable = "none",
                reportMissingImports = "none",
              },
            },
          },
          pyright = {
            disableOrganizeImports = true,
          },
        },
      }

      vim.lsp.config["ruff"] = {
        capabilities = {
          hoverProvider = false,
        },
      }

      vim.lsp.config["gopls"] = {
        formatting = {
          gofumpt = true,
        },
      }

      vim.lsp.config["tinymist"] = {
        settings = {
          formatterMode = "typstyle",
          exportPdf = "onType",
          semanticTokens = "disable",
        },
      }

      vim.lsp.config["bashls"] = {
        filetypes = { "sh", "bash", "zsh", "csh" },
        settings = {
          bashIde = {
            globPattern = "**/*@(.sh|.inc|.bash|.zsh|.env|.csh|.command)",
            includeAllWorkspaceSymbols = true,
          },
        },
      }

      vim.lsp.config.jsonls = {
        init_options = {
          provideFormatter = true,
        },
      }

      vim.lsp.config.lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Disable',
              keywordSnippet = 'Disable',
            }
          }
        }
      }
      vim.lsp.config["rust_analyzer"] = {
        settings = {
          ["rust-analyzer"] = {
            completion = {
              capable = {
                snippets = "add_parenthesis"
              },
            },
            diagnostics = {
              enable = true,
            }
          }
        }
      }

      -- vim.lsp.config.ty = {
      --   cmd = { "ty", "server" },
      --   workspace_required = true,
      --   root_markers = { "requirements.txt", ".venv", "pyproject.toml", "ty.toml" },
      -- }

      vim.lsp.config.texlab = {
        settings = {
          texlab = {
            rootDirectory = ".",
            bibtexFormatter = "texlab",
            build = {
              args = { "-pdf", "-pdflatex=lualatex", "-interaction=nonstopmode", "-synctex=1", "%f" },
              executable = "latexmk",
              forwardSearchAfter = false,
              onSave = false
            },
            forwardSearch = {
              executable = "zathura",
              args = { "--synctex-forward", "%l:1:%f", "%p" },
            },
            chktex = {
              onEdit = false,
              onOpenAndSave = true,
            },
            diagnosticsDelay = 400,
            formatterLineLength = 80,
            latexFormatter = "latexindent",
          }
        }
      }

      vim.lsp.enable({
        "bashls",
        "clangd",
        "cssls",
        "gopls",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        -- "ty",
        "pyright",
        "ruff",
        "rust_analyzer",
        "taplo",
        "texlab",
        "tinymist",
        "ts_ls",
        "vimls",
        "yamlls",
      })

      local function trigger_workspace_diagnostics(client, bufnr, workspace_files)
        if vim.tbl_contains(LOADED_CLIENTS, client.id) then
          return
        end
        table.insert(LOADED_CLIENTS, client.id)

        if not vim.tbl_get(client.server_capabilities, "textDocumentSync", "openClose") then
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
              uri = vim.uri_from_fname(vim.fn.fnamemodify(path, ":p")),
              version = 0,
              text = vim.fn.join(vim.fn.readfile(path), "\n"),
              languageId = filetype
            }
          }
          client.notify("textDocument/didOpen", params)
        end
      end

      vim.api.nvim_create_autocmd({ "CursorHold" },
        {
          group = vim.api.nvim_create_augroup("LSP_DIAGNOSTICS", { clear = true }),
          pattern = "*",
          callback = function()
            for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
              if vim.api.nvim_win_get_config(winid).zindex then
                return
              end
            end
            vim.diagnostic.open_float()
          end,
        }
      )

      local augroup = vim.api.nvim_create_augroup("LSP_ATTACH", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach",
        {
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client == nil then return end

            local capabilities = client.server_capabilities
            if capabilities == nil then return end

            if capabilities.diagnosticProvider then
              vim.api.nvim_clear_autocmds({ group = augroup, buffer = ev.buf })
              vim.api.nvim_create_autocmd("BufWritePre",
                {
                  group = augroup,
                  buffer = ev.buf,
                  callback = function()
                    local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                    if diagnostics and #diagnostics > 0 then
                      return
                    end
                    vim.lsp.buf.format({ async = false })
                  end
                }
              )
            end

            trigger_workspace_diagnostics(client, ev.buf, require("workout").git_files())
          end,
        }
      )

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

      vim.keymap.del({ "n", "x" }, "gra")
      vim.keymap.del({ "n" }, "gri")
      vim.keymap.del({ "n" }, "grn")
      vim.keymap.del({ "n" }, "grr")

      vim.keymap.set({ "n", "x" }, "gad", vim.diagnostic.setqflist,
        { noremap = true, silent = true, desc = "Diagnostics" })
      vim.keymap.set({ "n", "x" }, "gal", vim.lsp.buf.code_action,
        { noremap = true, silent = true, desc = "Action list" })
      vim.keymap.set({ "n", "x" }, "gar", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename" })
      vim.keymap.set({ "n", "x" }, "gaf", vim.lsp.buf.format, { noremap = true, silent = true, desc = "Format" })

      vim.keymap.set({ "n", "x" }, "gsd", vim.lsp.buf.definition,
        { noremap = true, silent = true, desc = "Symb definition" })
      vim.keymap.set({ "n", "x" }, "gsD", vim.lsp.buf.declaration,
        { noremap = true, silent = true, desc = "Symb declaration" })
      vim.keymap.set({ "n", "x" }, "gst", vim.lsp.buf.type_definition,
        { noremap = true, silent = true, desc = "Symb type" })
      vim.keymap.set({ "n", "x" }, "gsi", vim.lsp.buf.implementation,
        { noremap = true, silent = true, desc = "Symb implementations" })
      vim.keymap.set({ "n", "x" }, "gsr", vim.lsp.buf.references,
        { noremap = true, silent = true, desc = "Symb references" })

      vim.keymap.set({ "n", "x" }, "gsut", function() vim.lsp.buf.typehierarchy("supertypes") end,
        { noremap = true, silent = true, desc = "Symb upper types" })
      vim.keymap.set({ "n", "x" }, "gslt", function() vim.lsp.buf.typehierarchy("subtypes") end,
        { noremap = true, silent = true, desc = "Symb lower types" })

      vim.keymap.set({ "n", "x" }, "gsuc", vim.lsp.buf.outgoing_calls,
        { noremap = true, silent = true, desc = "Symb calling" })
      vim.keymap.set({ "n", "x" }, "gslc", vim.lsp.buf.incoming_calls,
        { noremap = true, silent = true, desc = "Symb called by" })
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
