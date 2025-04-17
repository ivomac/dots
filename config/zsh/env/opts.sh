
export ZDOTDIR="$HOME/.config/zsh"

export ESCDELAY=0

export LC_ALL="C.UTF-8"
export LC_TIME="C.UTF-8"
export LC_COLLATE="C"

export NO_AT_BRIDGE=1

export GPG_TTY=$(tty)

# DIRECTORIES

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export BIN="$HOME/.local/bin"
export LIB="$HOME/.local/lib"
export DOWNLOADS="$HOME/Downloads"
export DOCS="$HOME/Docs"
export PROJECTS="$HOME/Projects"
export MEDIA="$HOME/Media"
export BIB="$DOCS/.bib"

# EXECUTABLES

export MENU="menu"

export TERMINAL="footclient"
export TERMCMD=$TERMINAL
export OPEN="yazi_cwd"
export EXPLORER="yazi_cwd"
export PICKER="picker"
export PAGER="less"
export EDITOR="nvim"
export VISUAL="nvim"

export SUDO_ASKPASS="$BIN/sudo-pass"
export SSH_ASKPASS="$BIN/ssh-pass"

# HISTORY

export HISTFILE="$ZDOTDIR/cache/histfile"
export HISTSIZE=10000
export SAVEHIST=10000

export LESSHISTFILE="/dev/null"

# CONFIG FILES

export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

export RIPGREP_CONFIG_PATH="$ZDOTDIR/config/rg"
export ABBR_USER_ABBREVIATIONS_FILE="$ZDOTDIR/config/abbreviations"
export STARSHIP_CONFIG="$ZDOTDIR/config/starship.toml"

export AIDER_CONFIG="$XDG_CONFIG_HOME/aider/config.yml"
export AIDER_CONVENTIONS="/home/ivo/.config/aider/CONVENTIONS.md"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

export PASSWORD_STORE_DIR="$XDG_CONFIG_HOME/password-store"
export PASSWORD_STORE_ENABLE_EXTENSIONS=true

export BAT_THEME_LIGHT="gruvbox-light"
export BAT_THEME_DARK="gruvbox-dark"

# PYTHON CONFIG

export PYTHONPATH="$LIB/python"
export PYTHONOPTIMIZE=0
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/tmp/pycache"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/tmp/mypycache"

# SYSTEMD NOTIFY

export NOTIFY_SOCKET="$XDG_RUNTIME_DIR/systemd/notify"

# ADD TO PATH

if [[ ":$PATH:" != *":$BIN:"* ]]; then
	export PATH="${PATH:+"$PATH:"}$BIN"
fi

