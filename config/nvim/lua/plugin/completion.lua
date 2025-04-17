return {

	{
		"danymat/neogen",
		opts = {
			snippet_engine = "nvim",
		},
		keys = {
			{ "<leader>d", function() require("neogen").generate() end, silent = true, desc = "Generate Neogen" },
		},
	},

	{
		"zbirenbaum/copilot.lua",
		cmd = { "Copilot" },
		opts = {
			panel = {
				enabled = true,
				auto_refresh = false,
				keymap = {
					jump_prev = "[p",
					jump_next = "]p",
					accept = "<CR>",
					refresh = "=p",
					open = "<C-h>"
				},
				layout = {
					position = "bottom",
					ratio = 0.32
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-j>",
					accept_word = false,
					accept_line = false,
					next = false,
					prev = false,
					dismiss = false,
				},
			},
			filetypes = {
				yaml = true,
				markdown = true,
				["."] = true,
			},
		},
		keys = {
			{ "=c", function() vim.cmd.Copilot("toggle") end, silent = true, desc = "Toggle Copilot" },
		},
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"zbirenbaum/copilot.lua",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"petertriho/cmp-git",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
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
					},
				},
				sources = cmp.config.sources(
					{
						{ name = "local_snips" },
						{ name = "nvim_lsp" },
						{ name = "nvim_lsp_signature_help" },
					},
					{
						{ name = "buffer" },
					}
				),
				view = {
					docs = {
						auto_open = true,
					},
				},
				formatting = {
					fields = { "kind", "abbr" },
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({
							mode = "text",
							maxwidth = {
								menu = 50,
								abbr = 50,
							},
							ellipsis_char = '…',
							show_labelDetails = true,
						})(entry, vim_item)
						return kind
					end,
				}
			})

			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git' },
				}, {
					{ name = 'buffer' },
				})
			})
			require("cmp_git").setup()

			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{
						name = 'cmdline',
						option = {
							ignore_cmds = { 'Man', '!' }
						}
					}
				}),
				matching = { disallow_symbol_nonprefix_matching = false }
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
				"<C-d>",
				function()
					if require("cmp").visible() then
						local entry = require("cmp").get_selected_entry()
						if entry == nil then
							require("cmp").select_next_item()
						end
						require("cmp").confirm({ select = true })
					else
						local key = vim.api.nvim_replace_termcodes("<C-d>", true, false, true)
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
