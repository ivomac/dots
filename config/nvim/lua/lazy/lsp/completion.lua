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
    "milanglacier/minuet-ai.nvim",
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
    end,
    keys = {
      {
        mode = { "i", "s", "c" },
        "<C-k>",
        function()
          require("cmp").close()
          require("minuet.virtualtext").action.next()
        end,
        noremap = true,
        silent = true,
        desc = "Trigger Minuet"
      }
    },
  },

  {
    "hrsh7th/nvim-cmp",
    event = { "CmdlineEnter", "InsertEnter" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      -- "hrsh7th/cmp-buffer",
      -- "lukas-reineke/cmp-rg",
      "ivomac/cmp-neosnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        performance = {
          max_view_entries = 20,
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        window = {
          completion = {
            scrolloff = 0,
            scrollbar = true,
            zindex = 20,
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            col_offset = -3,
            side_padding = 1,
            preselect = cmp.PreselectMode.None,
          },
          documentation = {
            scrolloff = 0,
            scrollbar = true,
            zindex = 21,
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            col_offset = 0,
            side_padding = 1,
            preselect = cmp.PreselectMode.None,
          },
        },
        matching = {
          disallow_fuzzy_matching = true,
          disallow_fullfuzzy_matching = true,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
          disallow_symbol_nonprefix_matching = false,
        },
        sources = cmp.config.sources(
          {
            { name = "lazydev" },
            { name = "neosnip" },
            { name = "path" },
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            -- {
            --   name = "buffer",
            --   keyword_length = 3,
            --   max_item_count = 4,
            --   option = {
            --     get_bufnrs = function()
            --       local buf = vim.api.nvim_get_current_buf()
            --       local max_filesize = 800 * 1024 -- 800 KB
            --       local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            --       if ok and stats and stats.size > max_filesize then
            --         return {}
            --       end
            --       return { buf }
            --     end,
            --     indexing_interval = 1000,
            --   },
            -- },
            -- {
            --   name = "rg",
            --   keyword_length = 3,
            --   max_item_count = 4,
            --   option = {
            --     additional_arguments = "--smart-case --hidden",
            --   },
            -- },
          }
        ),
        view = {
          docs = {
            auto_open = true,
          },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = require("lspkind").cmp_format({
            mode = "symbol",
            maxwidth = {
              menu = 12,
              abbr = 60,
            },
            ellipsis_char = "…",
            show_labelDetails = true,
            before = function(_, vim_item)
              vim_item.menu = string.format("  (%s)", vim_item.kind)
              return vim_item
            end
          })
        }
      })

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "git" },
        }, {
          { name = "buffer" },
        })
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" }
            }
          }
        })
      })
    end,
    keys = {
      {
        mode = { "i", "s", "c" },
        "<C-n>",
        function()
          require("cmp").select_next_item()
        end,
        noremap = true,
        silent = true,
        desc = "Next completion"
      },
      {
        mode = { "i", "s", "c" },
        "<C-p>",
        function()
          require("cmp").select_prev_item()
        end,
        noremap = true,
        silent = true,
        desc = "Previous completion"
      },
      {
        mode = { "i", "s", "c" },
        "<C-j>",
        function()
          if require("minuet.virtualtext").action.is_visible() then
            require("minuet.virtualtext").action.accept()
          elseif require("cmp").visible() then
            local entry = require("cmp").get_selected_entry()
            if entry == nil then
              require("cmp").select_next_item()
            end
            require("cmp").confirm({ select = true })
          else
            local key = vim.api.nvim_replace_termcodes("<C-j>", true, false, true)
            vim.api.nvim_feedkeys(key, "nt", false)
          end
        end,
        noremap = true,
        silent = true,
        desc = "Accept"
      },
      {
        mode = { "i", "s" },
        "<C-l>",
        function()
          if vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
          end
        end,
        noremap = true,
        silent = true,
        desc = "Snip Next",
      },
      {
        mode = { "i", "s" },
        "<C-h>",
        function()
          if vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
          end
        end,
        noremap = true,
        silent = true,
        desc = "Snip Prev",
      },
    },
  },

}
