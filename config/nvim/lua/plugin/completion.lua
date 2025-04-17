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
		"Exafunction/windsurf.nvim",
		dependencies = { "nvim-lua/plenary.nvim", },
		config = function()
			require("codeium").setup({
				enable_cmp_source = false,
				virtual_text = {
					enabled = true,
					manual = true,
					map_keys = false,
				}
			})
		end,
		keys = {
			{
				"<C-k>",
				function()
					if require("cmp").visible() then
						require("cmp").close()
						require("cmp").close_docs()
					end
					require("codeium.virtual_text").cycle_or_complete()
				end,
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Codeium"
			},
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
			"Exafunction/windsurf.nvim",
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
						symbol_map = {
							Codeium = "",
						},
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
					local vt = require("codeium.virtual_text")

					if vt.status().state == "completions" then
						local completion_text = require("codeium.virtual_text").get_current_completion_item().completion
							.text
						local completion_lines = vim.split(completion_text, "\n")
						local first_line = completion_lines[1]
						local first_line_has_tabs = first_line:find("\t")

						local current_line = vim.api.nvim_get_current_line()
						local current_line_has_tabs = current_line:find("\t")

						local start = nil
						if current_line_has_tabs == first_line_has_tabs then
							start = vim.fn.col(".")
						else
							start = vim.fn.virtcol(".")
						end

						-- print("completion_text =", completion_text)
						-- print("current_line =", current_line)
						-- local stop = nil
						-- local curr_i = #current_line
						-- for comp_i = #first_line, start, -1 do
						--                       if current_line[curr_i] ~= first_line[comp_i] then
						--                           stop = comp_i
						--                           break
						--                       end
						-- 	print(string.format("start=%i  comp_i=%i/%i  curr_i=%i/%i ", start, comp_i, #first_line, curr_i, #current_line))
						-- 	curr_i = curr_i - 1
						--                   end

						completion_lines[1] = completion_lines[1]:sub(start) -- , stop
						vim.api.nvim_put(completion_lines, "v", false, true)
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
				silent = true,
				mode = { "i", "s", "c" },
				desc = "Accept"
			},
		},
	},

}
