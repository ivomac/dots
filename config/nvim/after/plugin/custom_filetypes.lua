vim.filetype.add({
	pattern = {
		["${DOCS}/Diary/.*txt"] = "diary",
		["*.zsh"] = "zsh",
		["*.jsonc"] = "jsonc",
	},
})
