#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"
source "$CURRENT_DIR/scripts/tree_helpers.sh"

set_default_key_binding_options() {
	local tree_command="$(tree_command)"
	local tree_key="$(tree_key)"
	local tree_focus_key="$(tree_focus_key)"
	local tree_pager="$(tree_pager)"
	local tree_position="$(tree_position)"
	local tree_width="$(tree_width)"

	set_tmux_option "${VAR_KEY_PREFIX}-${tree_key}" "$tree_command | ${tree_pager},${tree_position},${tree_width}"
	set_tmux_option "${VAR_KEY_PREFIX}-${tree_focus_key}" "$tree_command | ${tree_pager},${tree_position},${tree_width},focus"
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
