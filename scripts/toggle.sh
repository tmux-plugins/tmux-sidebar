#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

# script global vars
ARGS="$1"               # example args format: "tree | less,right,20,focus"
PANE_ID="$2"
COMMAND="$(echo "$ARGS"  | cut -d',' -f1)"   # "tree | less"
POSITION="$(echo "$ARGS" | cut -d',' -f2)"   # "right"
SIZE="$(echo "$ARGS"     | cut -d',' -f3)"   # "20"
FOCUS="$(echo "$ARGS"    | cut -d',' -f4)"   # "focus"

PANE_WIDTH="$(get_pane_info "$PANE_ID" "#{pane_width}")"
PANE_CURRENT_PATH="$(get_pane_info "$PANE_ID" "#{pane_current_path}")"

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

sidebar_pane_args() {
	echo "$(sidebar_registration)" |
		cut -d',' -f2-
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

current_pane_width_not_changed() {
	if [ $PANE_WIDTH -eq $1 ]; then
		return 0
	else
		return 1
	fi
}

kill_sidebar() {
	# get data before killing the sidebar
	local sidebar_pane_id="$(sidebar_pane_id)"
	local sidebar_args="$(sidebar_pane_args)"
	local sidebar_position="$(echo "$sidebar_args" | cut -d',' -f2)" # left or defults to right
	local sidebar_width="$(get_pane_info "$sidebar_pane_id" "#{pane_width}")"

	$CURRENT_DIR/save_sidebar_width.sh "$PANE_CURRENT_PATH" "$sidebar_width"

	# kill the sidebar
	tmux kill-pane -t "$sidebar_pane_id"

	# check current pane "expanded" properly
	local new_current_pane_width="$(get_pane_info "$PANE_ID" "#{pane_width}")"
	if current_pane_width_not_changed "$new_current_pane_width"; then
		# need to expand current pane manually
		local direction_flag
		if [[ "$sidebar_position" =~ "left" ]]; then
			direction_flag="-L"
		else
			direction_flag="-R"
		fi
		# compensate 1 column
		tmux resize-pane "$direction_flag" "$((sidebar_width + 1))"
	fi
	PANE_WIDTH="$new_current_pane_width"
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

# this is done just to refresh the main pane. See github issue #14.
touch_resize_main_pane() {
	if sidebar_left; then
		tmux resize-pane -t "$PANE_ID" "-R" 1
	else
		tmux resize-pane -t "$PANE_ID" "-L" 1
	fi
}

create_sidebar() {
	local sidebar_info=$(tmux split-window "$(orientation_option)" -c "$PANE_CURRENT_PATH" -P -F "#{pane_id},#{pane_width}" "$COMMAND")
	local sidebar_id=$(echo "$sidebar_info" | cut -d',' -f1)
	local sidebar_width=$(echo "$sidebar_info" | cut -d',' -f2)  # half a pane
	register_sidebar "$sidebar_id"
	register_sidebar_for_current_pane "$sidebar_id"
	if sidebar_left; then
		tmux swap-pane -U
	fi
	if directory_in_sidebar_file "$PANE_CURRENT_PATH"; then
		# use stored sidebar width for the directory
		local saved_width="$(width_from_sidebar_file "$PANE_CURRENT_PATH")"
		tmux resize-pane -x "$((saved_width - 1))"
	elif size_defined && [ $SIZE -lt $sidebar_width ]; then
		tmux resize-pane -x "$((SIZE - 1))"
	fi
	if no_focus; then
		tmux last-pane
	fi
	touch_resize_main_pane
}

current_pane_is_sidebar() {
	local var="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	[ -n "$var" ]
}

current_pane_too_narrow() {
	[ $PANE_WIDTH -lt 81 ]
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
