
local _FZF_NAV_DIR="$ZDOTDIR/plugins/fzf-nav"

local _FZF_NAV_OUT="/tmp/fzf-nav.$$.out"

local _FZF_NAV_DETACH='nohup \$TERMINAL -e zsh -ic \"\$OPEN {1}\" &>/dev/null &'

local _FZF_NAV_RG='
echo "change-input-label( 󱎸 Grep )+reload:$FZF_NAV_RG_COMMAND \"${FZF_QUERY:-.}\""
'

local _FZF_NAV_FD='
label="ERR"
if [[ $FZF_INPUT_LABEL =~ Search ]]; then
	flag="--type=d"
	label="󰥨 Directories"
elif [[  $FZF_INPUT_LABEL =~ Directories ]]; then
	flag="--type=f"
	label="󰱼 Files"
else
	flag=""
	label="󱈇 Search"
fi
echo "change-input-label( $label )+reload:$FZF_NAV_FD_COMMAND $flag"
'

local _FZF_NAV_LAZYGIT='
if [[ -d {1} ]]; then
	builtin cd {1}
else
	builtin cd "$(dirname {1})"
fi
lazygit
'

local _FZF_NAV_PREVIEW_LABEL='
local file=$(basename {1})
local digit={2}
if [[ $digit =~ ^[0-9]+$ ]]; then
	echo "change-preview-label( $file +$digit )"
else
	echo "change-preview-label( $file )"
fi
'

local _D=$(echo "${FZF_NAV_RG_COMMAND}" | grep -oE -- "--field-match-separator=[^ ]+" | cut -d= -f2)

function redir_out() {
	printf "echo -n '$1\n{1}\n{2}' > $_FZF_NAV_OUT"
}

function _fzf-open() {
	if [[ -z "$BUFFER" ]]; then
		fzf \
		--ansi \
		--scheme=path \
		--delimiter="$_D" \
		--preview="preview --line={2} {1}" \
		--header="\
↵:CD+O  O:Open  U:CD    E:Edit  D:Op&   L:LGit
F:Find  R:Grep  S:Jump  Y:Yank  T:Prev " \
		--bind="focus:transform:$_FZF_NAV_PREVIEW_LABEL" \
		--bind="start,ctrl-f:transform:$_FZF_NAV_FD" \
		--bind="ctrl-r:transform:$_FZF_NAV_RG" \
		--bind="ctrl-e:execute:$EDITOR +{2} {1}" \
		--bind="ctrl-d:execute-silent:$_FZF_NAV_DETACH" \
		--bind="ctrl-l:execute:$_FZF_NAV_LAZYGIT" \
		--bind="enter:become:$(redir_out CD)" \
		--bind="ctrl-o:become:$(redir_out NO)" \
		--bind="ctrl-u:become:$(redir_out CDONLY)"

		if [[ -f "$_FZF_NAV_OUT" ]]; then
			{
			  IFS= read -r CD
			  IFS= read -r file
			  IFS= read -r line
			} < "$_FZF_NAV_OUT"
			rm "$_FZF_NAV_OUT"
			if [[ -f "$file" ]] || [[ -d "$file" ]]; then
				file=$(realpath --strip "$file")
				if [[ "$CD" =~ "CD" ]]; then
					[[ -d "$file" ]] && builtin cd "$file" || builtin cd "$(dirname "$file")"
				fi
				if [[ "$CD" != "CDONLY" ]]; then
					opts="${line:++$line}"
					file=$(printf %q "$file")
					BUFFER="\$OPEN $file $opts"
				fi
				zle accept-line
			fi
		fi

	else
		zle fzf-tab-complete
	fi
}
zle -N _fzf-open

