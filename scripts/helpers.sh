get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option=$1
	local value=$2
	tmux set-option -gq "$option" "$value"
}

# Ensures a message is displayed for 5 seconds in tmux prompt.
# Does not override the 'display-time' tmux option.
display_message() {
	local message="$1"

	# display_duration defaults to 5 seconds, if not passed as an argument
	if [ "$#" -eq 2 ]; then
		local display_duration="$2"
	else
		local display_duration="5000"
	fi

	# saves user-set 'display-time' option
	local saved_display_time=$(get_tmux_option "display-time" "750")

	# sets message display time to 5 seconds
	tmux set-option -gq display-time "$display_duration"

	# displays message
	tmux display-message "$message"

	# restores original 'display-time' value
	tmux set-option -gq display-time "$saved_display_time"
}

stored_key_vars() {
	tmux show-options -g |
		\grep -i "^${VAR_KEY_PREFIX}-" |
		cut -d ' ' -f1 |               # cut just the variable names
		xargs                          # splat var names in one line
}

# get the key from the variable name
get_key_from_option_name() {
	local option="$1"
	echo "$option" |
		sed "s/^${VAR_KEY_PREFIX}-//"
}

get_value_from_option_name() {
	local option="$1"
	echo "$(get_tmux_option "$option" "")"
}

get_pane_info() {
	local pane_id="$1"
	local format_strings="#{pane_id},$2"
	tmux list-panes -t "$pane_id" -F "$format_strings" |
		\grep "$pane_id" |
		cut -d',' -f2-
}

sidebar_dir() {
	echo "$SIDEBAR_DIR"
}

sidebar_file() {
	echo "$(sidebar_dir)/directory_widths.txt"
}

directory_in_sidebar_file() {
	local pane_current_path="$1"
	grep -q "^${pane_current_path}\t" $(sidebar_file) 2>/dev/null
}

width_from_sidebar_file() {
	local pane_current_path="$1"
	grep "^${pane_current_path}\t" $(sidebar_file) |
		cut -f2
}

# function is used to get "clean" integer version number. Examples:
# `tmux 1.9` => `19`
# `1.9a`     => `19`
_get_digits_from_string() {
	local string="$1"
	local only_digits="$(echo "$string" | tr -dC '[:digit:]')"
	echo "$only_digits"
}

tmux_version_int() {
	local tmux_version_string=$(tmux -V)
	echo "$(_get_digits_from_string "$tmux_version_string")"
}
