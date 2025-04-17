return {
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    opts = { app = { "firefox", "-P", "Minimal" }, theme = "light" },
  },
}
