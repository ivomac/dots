#!/bin/env zsh

exit 0

case $1 in
period-changed)
  if [[ "$2" == "daytime" ]] && [[ "$3" == "transition" ]]; then
    exec notify-send "Dusk" "It's getting dark"
  elif [[ "$2" == "night" ]] && [[ "$3" == "transition" ]]; then
    exec notify-send "Dawn" "The sun is rising"
  elif [[ "$2" == "transition" ]] && [[ "$3" == "daytime" ]]; then
    exec notify-send "Morning" "Go get some sunshine"
  elif [[ "$2" == "transition" ]] && [[ "$3" == "night" ]]; then
    exec notify-send "Evening" "Time to relax"
  fi
  ;;
esac
