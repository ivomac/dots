return {
	{ trigger = "h1",     body = "# $1\n\n$0" },
	{ trigger = "h2",     body = "## $1\n\n$0" },
	{ trigger = "h3",     body = "### $1\n\n$0" },
	{ trigger = "b",      body = "**$1**$0" },
	{ trigger = "i",      body = "_$1_$0" },
	{ trigger = "c",      body = "`$1`$0" },
	{ trigger = "cb",     body = "```\n$1\n```$0" },
	{ trigger = "link",   body = "[$1]($2)$0" },
	{ trigger = "img",    body = "![${1:alt}](${2:url})$0" },
	{ trigger = "imgtag", body = '<img src="$1" alt="$2" width="${3:250}"/>' },
	{ trigger = "ul",     body = "- $1\n- $0" },
	{ trigger = "ol",     body = "1. $1\n2. $0" },
	{ trigger = "task",   body = "- [ ] $1$0" },
	{ trigger = "quote",  body = "> $1\n\n$0" },
	{ trigger = "tbl",    body = "| ${1:Header1} | ${2:Header2} |\n| --- | --- |\n| ${3:Cell1} | ${4:Cell2} |\n$0" },
	{ trigger = "meta",   body = "---\ntitle: $1\ndate: ${2:$(date '+%Y-%m-%d')}\n---\n\n$0" },
}
