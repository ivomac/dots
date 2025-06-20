# LOAD THEME

function load_theme() {
	TERMCOLORS="$COLORS/OSC/default.ini"
	while IFS='=' read -r key value; do
		if [[ "$key" == "fg" ]]; then
			printf "\033]10;%s\033\\" "$value"
		elif [[ "$key" == "bg" ]]; then
			printf "\033]11;%s\033\\" "$value"
		else
			printf "\033]4;%s;%s\033\\" "$key" "$value"
		fi
	done < "$TERMCOLORS"
}

load_theme


# ZSH OPTIONS

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

unalias run-help && autoload run-help

stty -ixon

bindkey -e

# LOAD PLUGINS

function get_plug() {
  plug="$1"
  name=${plug:t}
  folder="$ZDOTDIR/plugins/$name"
  if [[ ! -d "$folder" ]]; then
    git clone --recurse-submodules --depth 1 "https://github.com/$plug" "$folder"
  fi
  echo "$folder/$name.plugin.zsh"
}

source $(get_plug "zsh-users/zsh-completions")

fpath=("$ZDOTDIR/completions/" "$ZDOTDIR/plugins/zsh-completions/src" $fpath)
autoload -Uz compinit && compinit -d "$ZDOTDIR/cache/completions"

plugs=(
  "ivomac/fzf-nav"
  "Aloxaf/fzf-tab"
  "olets/zsh-abbr"
  "zdharma-continuum/fast-syntax-highlighting"
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-autosuggestions"
)

for plug in "${plugs[@]}"; do
  source $(get_plug "$plug")
done

# PLUGIN CONFIG

zstyle ':completion:*' regular true
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# MARK PROMPTS

function precmd {
    if ! builtin zle; then
        print -n "\e]133;D\e\\"
    fi
	print -Pn "\e]133;A\e\\"
}

function preexec {
    print -n "\e]133;C\e\\"
}

# REPORT DIRECTORY CHANGES TO FOOT TERMINAL
## https://codeberg.org/dnkl/foot/wiki#spawning-new-terminal-instances-in-the-current-working-directory

function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function chpwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}

# AUTOCD ON YAZI EXIT

function yazi_cwd() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# PRINT THE CURRENT DIRECTORY CONTENTS ON CD

function cd() {
	builtin cd "$@" || return
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

# FUNCTION: toggle foreground/background

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
bindkey '^I' _fzf-open                        # Tab
bindkey '^[[Z' _cd-back-and-forth             # Shift+Tab
bindkey '^[[27;5;46~' _cd-up                  # Ctrl+.
bindkey '^Z' _foreground                      # Ctrl+Z

# LOAD STARSHIP PROMPT

eval "$(starship init zsh)"

