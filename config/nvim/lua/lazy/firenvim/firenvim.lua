return {
  "glacambre/firenvim",
  lazy = false,
  build = ":call firenvim#install(0)",
  config = function()
    vim.g.firenvim_config = {
      globalSettings = { alt = "all" },
      localSettings = {
        [".*"] = {
          cmdline  = "firenvim",
          priority = 0,
          takeover = "never"
        }
      }
    }
  end,
}
