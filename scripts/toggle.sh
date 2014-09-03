#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

# script global vars
ARGS="$1"       # example args format: "right,compact->tree | less"
OPTIONS="$(echo "$ARGS" | sed "s/${OPTION_DELIMITER}.*//")"   # "right,compact"
COMMAND="$(echo "$ARGS" | sed "s/.*${OPTION_DELIMITER}//")"   # "tree | less"

PANE_ID="$TMUX_PANE"


sidebar_pane_id() {
	get_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" ""
}

register_new_sidebar() {
	set_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" "$1"
}

pane_exists() {
	local pane_id="$1"
	tmux list-panes -F "#{pane_id}" 2>/dev/null |
		\grep -q "^${pane_id}$"
}

has_sidebar() {
	local sidebar_pane_id="$(sidebar_pane_id)"
	if [ -n $sidebar_pane_id ] && pane_exists "$sidebar_pane_id"; then
		return 0
	else
		return 1
	fi
}

kill_sidebar() {
	tmux kill-pane -t "$(sidebar_pane_id)"
}

orientation_option() {
	echo "-h"
}

sidebar_left() {
	[[ $OPTIONS =~ "left" ]]
}

no_focus() {
	return 0
}

create_sidebar() {
	local new_sidebar_id=$(tmux split-window "$(orientation_option)" -P -F "#{pane_id}" "$COMMAND")
	register_new_sidebar "$new_sidebar_id"
	if sidebar_left; then
		tmux swap-pane -U
	fi
	if no_focus; then
		tmux last-pane
	fi
}

toggle_sidebar() {
	if has_sidebar; then
		kill_sidebar
	else
		create_sidebar
	fi
}

main() {
	toggle_sidebar
}
main
