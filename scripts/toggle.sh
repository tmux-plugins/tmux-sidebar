#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

# script global vars
ARGS="$1"               # example args format: "tree | less,right,20,focus"
PANE_CURRENT_PATH="$2"
PANE_ID="$3"
COMMAND="$(echo "$ARGS"  | cut -d',' -f1)"   # "tree | less"
POSITION="$(echo "$ARGS" | cut -d',' -f2)"   # "right"
SIZE="$(echo "$ARGS"     | cut -d',' -f3)"   # "20"
FOCUS="$(echo "$ARGS"    | cut -d',' -f4)"   # "focus"

current_pane_info="$(tmux list-panes -t "$PANE_ID" -F "#{pane_id},#{pane_width},#{pane_current_path}" | \grep "$PANE_ID")"
PANE_WIDTH="$(echo "$current_pane_info" | cut -d',' -f2)"
PANE_CURRENT_PATH="$(echo "$current_pane_info" | cut -d',' -f3)"

supported_tmux_version_ok() {
	$CURRENT_DIR/check_tmux_version.sh "$SUPPORTED_TMUX_VERSION"
}

sidebar_registration() {
	get_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" ""
}

sidebar_pane_id() {
	sidebar_registration |
		cut -d',' -f1
}

register_sidebar() {
	set_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${1}" "sidebar"
}

register_sidebar_for_current_pane() {
	set_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" "$1,$ARGS"
}

registration_not_for_the_same_command() {
	local registered_args="$(sidebar_registration | cut -d',' -f2-)"
	[[ $ARGS != $registered_args ]]
}

sidebar_exists() {
	local pane_id="$(sidebar_pane_id)"
	tmux list-panes -F "#{pane_id}" 2>/dev/null |
		\grep -q "^${pane_id}$"
}

has_sidebar() {
	if [ -n "$(sidebar_registration)" ] && sidebar_exists; then
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
	[[ $POSITION =~ "left" ]]
}

no_focus() {
	if [[ $FOCUS =~ (^focus) ]]; then
		return 1
	else
		return 0
	fi
}

size_defined() {
	[ -n $SIZE ]
}

create_sidebar() {
	local new_sidebar_id=$(tmux split-window "$(orientation_option)" -c "$PANE_CURRENT_PATH" -P -F "#{pane_id}" "$COMMAND")
	register_sidebar "$new_sidebar_id"
	register_sidebar_for_current_pane "$new_sidebar_id"
	if sidebar_left; then
		tmux swap-pane -U
	fi
	if size_defined; then
		tmux resize-pane -x "$SIZE"
	fi
	if no_focus; then
		tmux last-pane
	fi
}

current_pane_is_sidebar() {
	local var="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	[ -n "$var" ]
}

current_pane_too_narrow() {
	[ $PANE_WIDTH -lt 51 ]
}

exit_unless_pane_can_have_sidebar() {
	if current_pane_is_sidebar; then
		display_message "Sidebars can't have sidebars!"
		exit
	fi
}

exit_if_pane_too_narrow() {
	if current_pane_too_narrow; then
		display_message "Pane too narrow for the sidebar"
		exit
	fi
}

toggle_sidebar() {
	if has_sidebar; then
		kill_sidebar
		# if using different sidebar command automatically open a new sidebar
		if registration_not_for_the_same_command; then
			create_sidebar
		fi
	else
		exit_if_pane_too_narrow
		create_sidebar
	fi
}

main() {
	if supported_tmux_version_ok; then
		exit_unless_pane_can_have_sidebar
		toggle_sidebar
	fi
}
main
