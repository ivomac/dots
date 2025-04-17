# DISABLE CTRL-S

stty -ixon

# ZSH OPTIONS

unalias run-help && autoload run-help

# HISTORY CONFIG

setopt append_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

setopt auto_cd cd_silent
setopt menu_complete
setopt long_list_jobs
setopt notify
setopt hash_list_all
setopt glob_dots

# LOAD FZF NAVIGATION

source "$ZDOTDIR/plugins/fzf-nav/fzf-nav.zsh"

# LOAD COMPLETIONS

fpath=("$ZDOTDIR/plugins/zsh-completions/src" $fpath)
autoload -Uz compinit && compinit -d "$ZDOTDIR/cache/completions"

# LOAD OTHER PLUGINS

bindkey -e

source "$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"
source "$ZDOTDIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$ZDOTDIR/plugins/zsh-abbr/zsh-abbr.zsh"

# PLUGIN CONFIG

zstyle ':completion:*' regular true
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview "eza -1 --color=always \$realpath"

# REPORT DIRECTORY CHANGES TO FOOT TERMINAL
## https://codeberg.org/dnkl/foot/wiki#spawning-new-terminal-instances-in-the-current-working-directory

function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

# SAVE DIRECTORY CHANGES IN A VARIABLE
## chpwd is called whenever the current directory changes:
## https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions

typeset -A PWD_HIST
PWD_HIST[$PWD]=1
function chpwd() {
	PWD_HIST[$PWD]=1
    (( ZSH_SUBSHELL )) || osc7-pwd
}

# AUTOCD ON YAZI EXIT

function yazi_cwd() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
	eza --icons=auto
}

# PRINT THE CURRENT DIRECTORY CONTENTS ON CD

function cd() {
	if [[ "$PWD" != "$1" ]]; then
		builtin cd "$@" || return
	fi
	eza --icons=auto
}

# FUNCTION: cd ..

function _cd-up() {
	if [[ -z "$BUFFER" ]]; then
		BUFFER="cd .."
		zle accept-line
	fi
}
zle -N _cd-up

# FUNCTION: cd - binding

function _cd-back-and-forth() {
	if [[ -z "$BUFFER" ]]; then
		BUFFER="cd -"
		zle accept-line
	else
		zle fzf-tab-complete
	fi
}
zle -N _cd-back-and-forth

# FUNCTION: toggle foregroung/background

function _foreground() {
	if [[ -z "$BUFFER" ]]; then
		BUFFER="fg"
		zle accept-line
	fi
}
zle -N _foreground

bindkey '^[[A' history-substring-search-up    # Up arrow
bindkey '^[[B' history-substring-search-down  # Down arrow
bindkey '^P' history-substring-search-up      # Ctrl+P
bindkey '^N' history-substring-search-down    # Ctrl+N
bindkey '^O' _fzf-open-from-history           # Ctrl+O
bindkey '^K' _fzf-cd-from-cd-history          # Ctrl+K
bindkey '^H' _fzf-run-command-from-history    # Ctrl+H
bindkey '^I' _fzf-open                        # Tab
bindkey '^[[Z' _cd-back-and-forth             # Shift+Tab
bindkey '^[[27;5;46~' _cd-up                  # Ctrl+.
bindkey '^Z' _foreground                      # Ctrl+Z

# LOAD STARSHIP PROMPT

eval "$(starship init zsh)"

