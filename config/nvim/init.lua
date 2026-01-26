vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

local imports = { { import = "lazy/base" } }

table.insert(imports, { import = "lazy/dev" })
table.insert(imports, { import = "lazy/lsp" })

require("lazy").setup(
  imports,
  {
    debug = false,
    defaults = {
      lazy = true,
      version = false,
    },
    change_detection = {
      enabled = false,
    },
    checker = {
      enabled = false,
    },
    ui = {
      browser = "firefox",
      border = "rounded",
      backdrop = 100,
    },
    dev = {
      path = vim.fn.stdpath("config") .. "/dev"
    },
    performance = {
      cache = {
        enabled = true,
      },
      rtp = {
        disabled_plugins = {
          "matchit",
          "matchparen",
          "netrwPlugin",
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  }
)

dofile(os.getenv("HOME") .. "/.local/colors/nvim/default.lua")
