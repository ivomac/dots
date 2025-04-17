return {
  { trigger = 'bang',   body = '#!/usr/bin/env python\n${0}' },
  { trigger = 'import', body = 'import ${1}\n${0}' },
  { trigger = 'from',   body = 'from ${1} import ${2}\n${0}' },
  { trigger = 'for',    body = 'for ${1} in ${2}:\n    $0' },
  { trigger = 'forr',   body = 'for ${1:i} in range(${2}):\n    $0' },
  { trigger = 'fore',   body = 'for ${1:i}, ${2} in enumerate(${3}):\n    $0' },
  { trigger = 'while',  body = 'while ${1}:\n    $0' },
  { trigger = 'if',     body = 'if ${1}:\n    $0' },
  { trigger = 'elif',   body = 'elif ${1}:\n    $0' },
  { trigger = 'else',   body = 'else:\n    $0' },
  { trigger = 'def',    body = 'def ${1}($2):\n    $0' },
  { trigger = 'ifmain', body = 'if __name__ == "__main__":\n    ${1:main()}' },
}
