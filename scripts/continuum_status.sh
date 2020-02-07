#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

print_status() {
	local save_int="$(get_tmux_option "$auto_save_interval_option")"
	local last_save_stamp="$(get_tmux_option $last_auto_save_option )"
	local current_stamp="$( date +%s )"
	local duration="$( bc <<< "$current_stamp - $last_save_stamp")"
	local status=""
	local style_wrap
	if [ $duration -gt 0 ]; then
		style_wrap="$(get_tmux_option "$status_on_style_wrap_option" "")"
		status="saved $(date +%M -d @"$duration" ) minutes ago"
	else
		style_wrap="$(get_tmux_option "$status_off_style_wrap_option" "")"
		status="off"
	fi

	if [ -n "$style_wrap" ]; then
		status="${style_wrap/$status_wrap_string/$status}"
	fi
	echo "$status"
}
print_status
