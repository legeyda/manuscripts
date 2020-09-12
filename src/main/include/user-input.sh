
function is-interactive() {
	tty -s || return 1
}

function is-gui() {
	is-interactive && return 1
	test -z "${DISPLAY:-}" && return 0
}

function user-input-invite() {
	if is-interactive; then
		echo "$@"
	fi
}


# fun: input dear user please input the value
# txt: output paramter input_result
function user-input-read() {
	if is-interactive; then
		local result
		read result
		echo "$result"
	else
		if ! external-tool-available zenity; then
			errcho zenity not installed
		fi
		zenity --title nnote --text "$@ " --entry 
	fi
}