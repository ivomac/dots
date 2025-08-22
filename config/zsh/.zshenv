for file in "$ZDOTDIR"/env/*.sh; do
  if [[ "$file" == "*wayland.sh" && -z "$WAYLAND_DISPLAY" ]]; then
    continue
  fi
  source "$file"
done

# LOAD LS COLORS

[[ -x "$(command -v dircolors)" ]] && eval "$(dircolors)"
