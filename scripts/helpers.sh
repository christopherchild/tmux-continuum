get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option="$1"
	local value="$2"
	tmux set-option -gq "$option" "$value"
}

# multiple tmux server detection helpers

current_tmux_server_pid() {
	echo "$TMUX" |
		cut -f2 -d","
}

all_tmux_processes() {
	# ignores `tmux source-file .tmux.conf` command used to reload tmux.conf
	ps -Ao "command pid" |
		\grep "^tmux" |
		\grep -v "^tmux source"
}

user_tmux_processes() {
	# selects only user processes
	# ignores `tmux source-file .tmux.conf` command used to reload tmux.conf
	# ignores `tmux a` or `tmux attach` to connect to running session
	ps -u $UID -o "command pid" | 
		\grep "^tmux" | 
		\grep -v "^tmux source" | 
		\grep -v -e "^tmux a" -e "^tmux attach"

}

number_tmux_processes_except_current_server() {
	user_tmux_processes |
		\grep -v " $(current_tmux_server_pid)$" |
		wc -l |
		sed "s/ //g"
}

number_current_server_client_processes() {
	tmux list-clients |
		wc -l |
		sed "s/ //g"
}

another_tmux_server_running_on_startup() {
	# there are 2 tmux processes (current tmux server + 1) on tmux startup
	[ "$(number_tmux_processes_except_current_server)" -gt 1 ]
}
