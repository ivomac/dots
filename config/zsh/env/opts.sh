export ZDOTDIR="$HOME/.config/zsh"

export ESCDELAY=0

export LC_ALL="C.UTF-8"
export LC_TIME="C.UTF-8"
export LC_COLLATE="C"

export NO_AT_BRIDGE=1

GPG_TTY=$(tty)
export GPG_TTY

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

export COLORS="$HOME/.local/colors"

export RUSTUP_HOME="$HOME/.cache"

# EXECUTABLES

export MENU="menu"

export TERMINAL="footclient"
export TERMCMD=$TERMINAL
export OPEN="yazi_cwd"
export EXPLORER="yazi_cwd"
export PICKER="yazi --chooser-file"
export PREVIEW="preview"
export PAGER="pager"
export MANPAGER="pager"
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

# PYTHON CONFIG

export PYTHONPATH="$LIB/python"
export PYTHONOPTIMIZE=0
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/tmp/pycache"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/tmp/mypycache"

# SYSTEMD NOTIFY

export NOTIFY_SOCKET="$XDG_RUNTIME_DIR/systemd/notify"

# FZF

color_str="--color=16,fg+:0,bg+:15,hl+:3,gutter:-1,pointer:4,marker:6"
for region in "input" "header" "preview"; do
  color_str+=",$region-fg:-1"
  color_str+=",$region-bg:-1"
  color_str+=",$region-border:3"
  color_str+=",$region-label:4"
done

export FZF_DEFAULT_OPTS="\
$color_str \
--ansi \
--height=100% \
--input-border=bottom \
--header-border=bottom \
--header='S:Jump · Y:Yank · T:All · \:Preview' \
--pointer='█' \
--marker='█' \
--input-label-pos='0:top' \
--info=inline-right \
--preview-window='right:50%:border-left:wrap:<60(down:60%:border-top:wrap)' \
--tiebreak='begin,length' \
--tabstop=2 \
--reverse \
--bind='change:top' \
--bind='tab:toggle-out' \
--bind='ctrl-t:toggle-all' \
--bind='ctrl-s:jump' \
--bind='ctrl-y:execute-silent:wl-copy {}' \
--bind='ctrl-\\:toggle-preview' \
"

FZF_NAV_FD_COMMAND="\
fd \
--color=always \
--hidden \
--no-ignore \
"

FZF_NAV_RG_COMMAND="\
rg \
--color=always \
--hidden \
--no-ignore \
--line-number \
--with-filename \
--field-match-separator=◇ \
--no-heading \
--smart-case \
"

FZF_NAV_SEARCH_EXCLUDE=(
  "**/.git/**"
  "**/.parallel/**"
  "**/.cargo/**"
  "**/.npm/**"
  "**/.pki/**"
  "**/.venv**/**"
  "**/__pycache__/**"
  "**/.ipython/**"
  "**/cache/**"
  "**/.cache/**"
  "**/.nvim/**"
  "**/nvim/undo/**"
  "**/.android/**"
  "**/.mozilla/firefox/*/**"
  "**/.stfolder/**"
  "**/.steam/**"
  "**/.aider*/**"
  "**/.local/share/*/**"
  "**/yazi/packages/**"
  "**/.bib/**"
)

for dir in "${FZF_NAV_SEARCH_EXCLUDE[@]}"; do
  if [[ -n "$dir" ]]; then
    FZF_NAV_FD_COMMAND+=' --exclude='"'$dir'"
    FZF_NAV_RG_COMMAND+=' --glob=!'"'$dir'"
  fi
done

export FZF_NAV_FD_COMMAND
export FZF_NAV_RG_COMMAND

export FZF_DEFAULT_COMMAND="$FZF_NAV_FD_COMMAND"

export FZF_NAV_BOOKMARKS_COMMAND="\
head -n1 '$XDG_STATE_HOME/yazi/.dds' \
| cut -d, -f4- \
| jq -r '.[] | \"\(.path)◇\(.desc)\"' \
"

export FZF_NAV_GITDIRS_COMMAND="$FZF_NAV_FD_COMMAND --type=dir '^\.git$' \"$PROJECTS\" -x echo {//}"
export FZF_NAV_GITSTATUS_COMMAND="mgitstatus --no-ok -c --depth 3 \"$PROJECTS\""
export FZF_NAV_GITFETCH_COMMAND="mgitstatus --no-ok -c --depth 3 -f \"$PROJECTS\""

# ADD TO PATH

if [[ ":$PATH:" != *":$BIN:"* ]]; then
  export PATH="${PATH:+"$PATH:"}$BIN"
fi
