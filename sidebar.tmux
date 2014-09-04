#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"

custom_tree_command="$CURRENT_DIR/scripts/custom_tree.sh"

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

tree_command() {
	if command_exists "tree"; then
		echo "tree"
	else
		echo "$custom_tree_command"
	fi
}

set_default_key_binding_options() {
	local tree_command="$(tree_command)"
	if key_not_defined "Tab"; then
		set_tmux_option "${VAR_KEY_PREFIX}-Tab" "$tree_command | less -S,left,40"
	fi
	if key_not_defined "Bspace"; then
		set_tmux_option "${VAR_KEY_PREFIX}-Bspace" "$tree_command | less -S,left,40,focus"
	fi
}

set_key_bindings() {
	local stored_key_vars="$(stored_key_vars)"
	local search_var
	local key
	local pattern
	for option in $stored_key_vars; do
		key="$(get_key_from_option_name "$option")"
		value="$(get_value_from_option_name "$option")"
		tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/toggle.sh '$value' '#{pane_id}'"
	done
}

main() {
	set_default_key_binding_options
	set_key_bindings
}
main
