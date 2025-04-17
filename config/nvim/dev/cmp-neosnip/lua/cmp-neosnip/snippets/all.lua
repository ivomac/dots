return {
  { trigger = 'bang', body = '#!/usr/bin/${1}\n\n${0}' },
  { trigger = 'bange', body = '#!/usr/bin/env ${1}\n\n${0}' }
}
