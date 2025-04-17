return {
	{ trigger = 'bang', body = '#!/usr/bin/env python$0' },
	{ trigger = 'import', body = 'import ${0:pkg}' },
	{ trigger = 'from', body = 'from ${1} import $0' },
	{ trigger = 'for', body = 'for ${1:it}:\n    $0' },
	{ trigger = 'while', body = 'while ${1:cond}:\n    $0' },
	{ trigger = 'if', body = 'if ${1:cond}:\n    $0' },
	{ trigger = 'elif', body = 'elif ${1:cond}:\n    $0' },
	{ trigger = 'else', body = 'else:\n    $0' },
	{ trigger = 'def', body = 'def ${1:fn}($2):\n    $0' },
	{ trigger = 'ifmain', body = 'if __name__ == "__main__":\n    ${1:main()}' },
}
