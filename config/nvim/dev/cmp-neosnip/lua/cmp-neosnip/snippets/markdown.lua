return {
  { trigger = "b",      body = "**${1}**${0}" },
  { trigger = "i",      body = "*${1}*${0}" },
  { trigger = "u",      body = "_${1}_${0}" },
  { trigger = "c",      body = "`${1}`${0}" },
  { trigger = "cb",     body = "```${1}\n${1}\n```\n${0}" },
  { trigger = "ln",     body = "[${1}](${2:url})${0}" },
  { trigger = "im",    body = "![${1}](${2:url})${0}" },
  { trigger = "imtag", body = '<img src="${1}" alt="${2}" width="${3}"/>\n${0}' },
  { trigger = "task",   body = "- [ ] ${1}${0}" },
  { trigger = "tbl",    body = "| ${1:Header1} | ${2:Header2} |\n| --- | --- |\n| ${3:Cell1} | ${4:Cell2} |\n${0}" },
}
