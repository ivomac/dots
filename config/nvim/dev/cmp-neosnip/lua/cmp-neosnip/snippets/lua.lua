return {
  { trigger = 'ifn', body = 'function(${1}) ${2} end${0}' },
  { trigger = 'fn',  body = 'function ${1}(${2})\n  ${3}\nend\n${0}' },
  { trigger = 'afn', body = 'function(${1})\n  ${2}\nend\n${0}' },
  { trigger = 'lfn', body = 'local function ${1}(${2})\n  ${3}\nend\n${0}' },
}
