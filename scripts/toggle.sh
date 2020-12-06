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
	local sidebar_id="$1"
	set_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${sidebar_id}" "$PANE_ID"
	set_tmux_option "${REGISTERED_PANE_PREFIX}-${PANE_ID}" "${sidebar_id},${ARGS}"
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

desired_sidebar_size() {
	local half_pane="$((PANE_WIDTH / 2))"
	if directory_in_sidebar_file "$PANE_CURRENT_PATH"; then
		# use stored sidebar width for the directory
		echo "$(width_from_sidebar_file "$PANE_CURRENT_PATH")"
	elif size_defined && [ $SIZE -lt $half_pane ]; then
		echo "$SIZE"
	else
		echo "$half_pane"
	fi
}

# tmux version 2.0 and below requires different argument for `join-pane`
use_inverted_size() {
	[ $(tmux_version_int) -le 20 ]
}

split_sidebar_left() {
	local sidebar_size=$(desired_sidebar_size)
	if use_inverted_size; then
		sidebar_size=$((PANE_WIDTH - $sidebar_size - 1))
	fi
	local sidebar_id="$(tmux new-window -c "$PANE_CURRENT_PATH" -P -F "#{pane_id}" "$COMMAND")"
	tmux join-pane -hb -l "$sidebar_size" -t "$PANE_ID" -s "$sidebar_id"
	echo "$sidebar_id"
}

split_sidebar_right() {
	local sidebar_size=$(desired_sidebar_size)
	tmux split-window -h -l "$sidebar_size" -c "$PANE_CURRENT_PATH" -P -F "#{pane_id}" "$COMMAND"
}

create_sidebar() {
	local position="$1" # left / right
	local sidebar_id="$(split_sidebar_${position})"
	register_sidebar "$sidebar_id"
	if no_focus; then
		tmux last-pane
	fi
}

current_pane_is_sidebar() {
	local var="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	[ -n "$var" ]
}

current_pane_too_narrow() {
	[ $PANE_WIDTH -lt $MINIMUM_WIDTH_FOR_SIDEBAR ]
}

execute_command_from_main_pane() {
	# get pane_id for this sidebar
	local main_pane_id="$(get_tmux_option "${REGISTERED_SIDEBAR_PREFIX}-${PANE_ID}" "")"
	# execute the same command as if from the "main" pane
	$CURRENT_DIR/toggle.sh "$ARGS" "$main_pane_id"
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
		# if registration_not_for_the_same_command; then
		# 	create_sidebar
		# fi
	else
		exit_if_pane_too_narrow
		if sidebar_left; then
			create_sidebar "left"
		else
			create_sidebar "right"
		fi
	fi
}

main() {
	if supported_tmux_version_ok; then
		if current_pane_is_sidebar; then
			execute_command_from_main_pane
		else
			toggle_sidebar
		fi
	fi
}
main
