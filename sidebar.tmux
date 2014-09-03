#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"

set_default_key_binding_options() {
	if key_not_defined "t"; then
		set_tmux_option "${VAR_KEY_PREFIX}-t" "left,compact->tree | less"
	fi
	if key_not_defined "T"; then
		set_tmux_option "${VAR_KEY_PREFIX}-T" "right,compact->tree | less"
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
		tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/toggle.sh '$value'"
	done
}

main() {
	set_default_key_binding_options
	set_key_bindings
}
main
