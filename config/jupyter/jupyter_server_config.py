c = get_config()

c.PasswordIdentityProvider.password_required = True
c.PasswordIdentityProvider.allow_password_change = False

c.ServerApp.autoreload = True

c.ServerApp.ip = "localhost"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False

c.ServerApp.allow_root = False
c.ServerApp.allow_remote_access = False
c.ServerApp.allow_unauthenticated_access = False

c.ServerApp.terminals_enabled = False
