return {

  {
    "chrisgrieser/nvim-various-textobjs",
    keys = {
      { "aE",     function() require("various-textobjs").entireBuffer() end,                desc = "An entire buffer", mode = { "o", "x" } },
      { "i<Tab>", function() require("various-textobjs").indentation("inner", "inner") end, desc = "In indent",        mode = { "o", "x" } },
      { "a<Tab>", function() require("various-textobjs").indentation("outer", "outer") end, desc = "An indent",        mode = { "o", "x" } },
      { "aj",     function() require("various-textobjs").column("both") end,                desc = "A column",         mode = { "o", "x" } },
      { "iu",     function() require("various-textobjs").subword("inner") end,              desc = "In subword",       mode = { "o", "x" } },
      { "au",     function() require("various-textobjs").subword("outer") end,              desc = "A subword",        mode = { "o", "x" } },
      { "iv",     function() require("various-textobjs").value("inner") end,                desc = "In value",         mode = { "o", "x" } },
      { "av",     function() require("various-textobjs").value("outer") end,                desc = "A value",          mode = { "o", "x" } },
      { "ik",     function() require("various-textobjs").key("inner") end,                  desc = "In key",           mode = { "o", "x" } },
      { "ak",     function() require("various-textobjs").key("outer") end,                  desc = "A key",            mode = { "o", "x" } },
      { "in",     function() require("various-textobjs").number("inner") end,               desc = "In number",        mode = { "o", "x" } },
      { "an",     function() require("various-textobjs").number("outer") end,               desc = "A number",         mode = { "o", "x" } },
      { "im",     function() require("various-textobjs").chainMember("inner") end,          desc = "In method",        mode = { "o", "x" } },
      { "am",     function() require("various-textobjs").chainMember("outer") end,          desc = "A method",         mode = { "o", "x" } },
      { "iS",     function() require("various-textobjs").pyTripleQuotes("inner") end,       desc = "In triple quotes", mode = { "o", "x" } },
      { "aS",     function() require("various-textobjs").pyTripleQuotes("outer") end,       desc = "A triple quotes",  mode = { "o", "x" } },
    },
  },

  {
    "thinca/vim-textobj-between",
    dependencies = { "kana/vim-textobj-user" },
    config = function()
      vim.g.textobj_between_no_default_key_mappings = 1
    end,
    keys = {
      { "ib", "<Plug>(textobj-between-i)", remap = true, silent = true, desc = "In between", mode = { "x", "o" } },
      { "ab", "<Plug>(textobj-between-a)", remap = true, silent = true, desc = "A between",  mode = { "x", "o" } },
    }
  },

}
