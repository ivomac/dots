return {

	{
		"chrisgrieser/nvim-various-textobjs",
		keys = {
			{ "i<Tab>",   function() require("various-textobjs").indentation("inner", "inner") end, desc = "In indent",        mode = { "o", "x" } },
			{ "a<Tab>",   function() require("various-textobjs").indentation("outer", "inner") end, desc = "An indent",        mode = { "o", "x" } },
			{ "a<S-Tab>", function() require("various-textobjs").indentation("outer", "outer") end, desc = "Outer indent",     mode = { "o", "x" } },
			{ "iu",       function() require("various-textobjs").subword("inner") end,              desc = "In subword",       mode = { "o", "x" } },
			{ "au",       function() require("various-textobjs").subword("outer") end,              desc = "A subword",        mode = { "o", "x" } },
			{ "iS",       function() require("various-textobjs").pyTripleQuotes("inner") end,       desc = "In triple quotes", mode = { "o", "x" } },
			{ "aS",       function() require("various-textobjs").pyTripleQuotes("outer") end,       desc = "A triple quotes",  mode = { "o", "x" } },
			{ "aE",       function() require("various-textobjs").entireBuffer() end,                desc = "An entire buffer", mode = { "o", "x" } },
			{ "iv",       function() require("various-textobjs").value("inner") end,                desc = "In value",         mode = { "o", "x" } },
			{ "av",       function() require("various-textobjs").value("outer") end,                desc = "A value",          mode = { "o", "x" } },
			{ "ik",       function() require("various-textobjs").key("inner") end,                  desc = "In key",           mode = { "o", "x" } },
			{ "ak",       function() require("various-textobjs").key("outer") end,                  desc = "A key",            mode = { "o", "x" } },
			{ "in",       function() require("various-textobjs").number("inner") end,               desc = "In number",        mode = { "o", "x" } },
			{ "an",       function() require("various-textobjs").number("outer") end,               desc = "A number",         mode = { "o", "x" } },
			{ "im",       function() require("various-textobjs").chainMember("inner") end,          desc = "In method",        mode = { "o", "x" } },
			{ "am",       function() require("various-textobjs").chainMember("outer") end,          desc = "A method",         mode = { "o", "x" } },
			{ "iP",       function() require("various-textobjs").shellPipe("inner") end,            desc = "In pipe",          mode = { "o", "x" } },
			{ "aP",       function() require("various-textobjs").shellPipe("outer") end,            desc = "A pipe",           mode = { "o", "x" } },
			{ "ix",       function() require("various-textobjs").htmlAttribute("inner") end,        desc = "In HTMLAttr",      mode = { "o", "x" } },
			{ "ax",       function() require("various-textobjs").htmlAttribute("outer") end,        desc = "An HTMLAttr",      mode = { "o", "x" } },
		},
	},

	{ "kana/vim-textobj-user" },

	{
		"glts/vim-textobj-comment",
		dependencies = { "kana/vim-textobj-user" },
		config = function()
			vim.g.textobj_comment_no_default_key_mappings = 1
		end,
		keys = {
			{ "io", "<Plug>(textobj-comment-i)",     remap = true, silent = true, desc = "in Comment",      mode = { "x", "o" } },
			{ "ao", "<Plug>(textobj-comment-a)",     remap = true, silent = true, desc = "a Comment",       mode = { "x", "o" } },
			{ "aO", "<Plug>(textobj-comment-big-a)", remap = true, silent = true, desc = "a Comment + \\s", mode = { "x", "o" } },
		}
	},

	{
		"ivomac/textobj-word-column.vim",
		event = "VeryLazy",
		dependencies = { "kana/vim-textobj-user" },
	},

}
