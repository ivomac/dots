return {

  {
    "danymat/neogen",
    opts = {
      snippet_engine = "nvim",
    },
    keys = {
      { "<leader>ad", function() require("neogen").generate() end, silent = true, desc = "Docstrings" },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },


  {
    "chrisgrieser/nvim-scissors",
    dependencies = {
      "ivomac/toothpick.nvim",
    },
    opts = {
      snippetDir = string.format("%s/snippets", vim.fn.stdpath("config")),
      editSnippetPopup = {
        height = 0.8,
        width = 0.8,
        border = "rounded",
        keymaps = {
          cancel = "<Esc>",
          saveChanges = "<CR>",
          goBackToSearch = "<BS>",
          deleteSnippet = "<C-BS>",
          duplicateSnippet = "<C-d>",
          openInFile = "<C-o>",
          insertNextPlaceholder = "<C-p>",
          showHelp = "?",
        },
      },
      snippetSelection = {
        picker = "vim.ui.select",
      },
      jsonFormatter = "jq",
      backdrop = {
        enabled = false,
      },
      icons = {
        scissors = "",
      },
    },
    keys = {
      { mode = { "n" },      "<leader>je", function() require("scissors").editSnippet() end,   noremap = true, silent = true, desc = "Edit" },
      { mode = { "n", "x" }, "<leader>jn", function() require("scissors").addNewSnippet() end, noremap = true, silent = true, desc = "New" },
    },
  },

  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup(
        {
          cmp = {
            enable_auto_complete = false,
          },
          blink = {
            enable_auto_complete = false,
          },
          virtualtext = {
            show_on_completion_menu = true,
            auto_trigger_ft = {},
            keymap = {
              accept = nil,
              accept_line = nil,
              accept_n_lines = nil,
              prev = nil,
              next = nil,
              dismiss = nil,
            },
          },
          provider = "gemini",
          context_window = 8000,
          context_ratio = 0.75,
          throttle = 1000,
          debounce = 500,
          notify = "warn",
          request_timeout = 4,
          add_single_line_entry = false,
          n_completions = 3,
          after_cursor_filter_length = 15,
          provider_options = {
            gemini = {
              stream = true,
              model = "gemini-2.5-flash-preview-05-20",
              api_key = "GEMINI_API_KEY",
              optional = {
                generationConfig = {
                  maxOutputTokens = 256,
                  thinkingConfig = {
                    thinkingBudget = 0,
                  },
                },
              },
            },
          }
        }
      )
    end
  },

  {
    "saghen/blink.cmp",
    event = { "CmdlineEnter", "InsertEnter" },
    build = "cargo build --release",
    opts = {
      cmdline = {
        enabled = true,
        sources = { "cmdline", "buffer" },
        keymap = {
          preset = "inherit",
          ["<Tab>"] = { "show_and_insert", "select_next" },
          ["<S-Tab>"] = { "show_and_insert", "select_prev" },
          ["<CR>"] = { "accept_and_enter", "fallback" },
        },
        completion = {
          menu = {
            auto_show = false,
          },
          list = {
            selection = {
              preselect = true,
              auto_insert = true,
            },
          },
        }
      },
      signature = {
        enabled = true,
        trigger = {
          enabled = true
        },
        window = {
          winblend = 0,
          winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:Visual,Search:None",
          scrollbar = false,
          treesitter_highlighting = true,
          show_documentation = true,
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            winblend = 0,
            scrollbar = true,
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          },
        },
        keyword = {
          range = "full",
        },
        list = {
          max_items = 30,
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
          winblend = 0,
          scrollbar = true,
          scrolloff = 0,
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
          auto_show = true,
          draw = {
            align_to = "cursor",
            columns = {
              { "label", "label_description", gap = 2 },
              { "kind",  "source_name",       gap = 2 }
            },
          }
        }
      },
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-s>"] = { "show_signature", "fallback" },
        ["<C-k>"] = {
          function(cmp)
            if not cmp.is_menu_visible() then
              require("minuet.virtualtext").action.next()
              return true
            else
              return false
            end
          end,
          "fallback"
        },
        ["<C-j>"] = {
          function(_)
            if require("minuet.virtualtext").action.is_visible() then
              require("minuet.virtualtext").action.accept()
              return true
            end
          end,
          "select_and_accept",
          "fallback"
        },
        ["<C-h>"] = { "snippet_backward", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono"
      },
      snippets = {
        preset = "default",
      },
      sources = {
        default = { "path", "snippets", "lsp", "buffer" },
        per_filetype = {
          lua = { "path", "snippets", "lazydev", "lsp", "buffer" },
        },
        providers = {
          lsp = {
            score_offset = 20,
          },
          path = {
            score_offset = 40,
          },
          snippets = {
            score_offset = 200,
            opts = {
              search_paths = {
                string.format("%s/snippets", vim.fn.stdpath("config")),
              },
              clipboard_register = '"',
              friendly_snippets = false,
            },
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 80,
          },
        }
      },
      fuzzy = { implementation = "rust" }
    },
    opts_extend = { "sources.default" }
  },

}
