return {
	{
		"toppair/peek.nvim",
		ft = { "markdown" },
		build = "deno task --quiet build:fast",
		opts = { app = "xdg-open", theme = "light" },
	},
}
