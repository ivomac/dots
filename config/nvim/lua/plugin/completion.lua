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

	{ "nvim-lua/plenary.nvim", },
	{ "onsails/lspkind.nvim", },
	{ "hrsh7th/cmp-nvim-lsp", },
	{ "hrsh7th/cmp-buffer", },
	{ "hrsh7th/cmp-path", },
	{ "hrsh7th/cmp-cmdline", },
	{ "hrsh7th/cmp-nvim-lsp-signature-help", },
	{ "lukas-reineke/cmp-rg", },

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
		"hrsh7th/nvim-cmp",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"lukas-reineke/cmp-rg",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				performance = {
					max_view_entries = 8,
				},
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				window = {
					completion = {
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
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
						{ name = "local_snips" },
						{ name = "path" },
						{ name = "nvim_lsp" },
						{ name = "nvim_lsp_signature_help" },
						{
							name = "buffer",
							keyword_length = 3,
							max_item_count = 4,
							option = {
								get_bufnrs = function()
									local buf = vim.api.nvim_get_current_buf()
									local max_filesize = 800 * 1024 -- 800 KB
									local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
									if ok and stats and stats.size > max_filesize then
										return {}
									end
									return { buf }
								end,
								indexing_interval = 1000,
							},
						},
						{
							name = "rg",
							keyword_length = 3,
							max_item_count = 4,
							option = {
								additional_arguments = "--smart-case --hidden",
							},
						},
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
				"<C-f>",
				function()
					if not require("cmp").visible_docs() then
						require("cmp").open_docs()
					else
						require("cmp").scroll_docs(2)
					end
				end,
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Scroll Docs Forward"
			},
			{
				"<C-s>",
				function()
					if not require("cmp").visible_docs() then
						require("cmp").open_docs()
					else
						require("cmp").scroll_docs(-2)
					end
				end,
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Scroll Docs Backward"
			},
			{
				"<C-n>",
				function()
					require("cmp").select_next_item()
				end,
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Next completion"
			},
			{
				"<C-p>",
				function()
					require("cmp").select_prev_item()
				end,
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Previous completion"
			},
			{
				"<C-j>",
				function()
					if require("cmp").visible() then
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
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Accept"
			},
		},
	},

}
