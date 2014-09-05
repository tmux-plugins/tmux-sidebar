# file sourced from ./sidebar.tmux
custom_tree_command="$CURRENT_DIR/scripts/custom_tree.sh"

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

tree_command() {
	local user_command="$(tree_user_command)"
	if [ -n "$user_command" ]; then
		echo "$user_command"
	elif command_exists "tree"; then
		echo "$TREE_COMMAND"
	else
		echo "$custom_tree_command"
	fi
}

tree_user_command() {
	get_tmux_option "$TREE_COMMAND_OPTION" ""
}

tree_key() {
	get_tmux_option "$TREE_OPTION" "$TREE_KEY"
}

tree_focus_key() {
	get_tmux_option "$TREE_FOCUS_OPTION" "$TREE_FOCUS_KEY"
}

tree_pager() {
	get_tmux_option "$TREE_PAGER_OPTION" "$TREE_PAGER"
}

tree_position() {
	get_tmux_option "$TREE_POSITION_OPTION" "$TREE_POSITION"
}

tree_width() {
	get_tmux_option "$TREE_WIDTH_OPTION" "$TREE_WIDTH"
}
