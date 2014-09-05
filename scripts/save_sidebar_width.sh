#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

DIR_PATH="$(echo "$1" | tail -1)" # fixes a bug with invalid param
WIDTH="$2"
delimiter=$'\t'

replace_directory_width() {
	sed "s|^${DIR_PATH}${delimiter}.*|${DIR_PATH}${delimiter}${WIDTH}|g" $(sidebar_file) > $(sidebar_file).bak
	mv $(sidebar_file).bak $(sidebar_file)
}

add_directory_width() {
	mkdir -p "$(sidebar_dir)"
	echo "${DIR_PATH}${delimiter}${WIDTH}" >> $(sidebar_file)
}

save_sidebar_width() {
	if directory_in_sidebar_file "$DIR_PATH"; then
		replace_directory_width
	else
		add_directory_width
	fi
}

main() {
	save_sidebar_width
}
main
