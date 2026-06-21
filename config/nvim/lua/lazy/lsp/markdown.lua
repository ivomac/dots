return {
  -- peek.nvim is unmaintained (last push Aug 2024, 37 open issues).
  -- Alternatives: MeanderingProgrammer/render-markdown.nvim, OXY2DEV/markview.nvim
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    opts = { app = { "firefox", "-P", "Minimal" }, theme = "light" },
  },
}
