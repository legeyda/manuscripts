
read-clipboard() {
	if installed xclip; then
		xclip -out || true
	else
		message xclip not installed
	fi
}

#fun: message hello
function message() {
	local msg="$@"
	echo "$msg"
	echo "$msg" >> $HOME/ERRORS
	if is-display-available; then
		if installed yad; then
			yad    --info --text "$msg" --title nnote	
		elif installed zenity; then
			zenity --info --text "$msg" --title nnote	
		else
			errcho 'neither yad nor zenity installed'
		fi
	fi	
}

function is-interactive-shell() {
	tty -s || return 1
}

function is-display-available() {
	test -n "${DISPLAY:-}" || return 1
}

# fun: question='input some value' title='window title' default='default value here' user-input
user-input-read() {
	if is-interactive-shell; then
		user-input-tui-read "$@"
	elif is-display-available; then
		user-input-gui-read "$@"
	else
		message 'error reading user inputs'
	fi
}


# fun: question='input some value' default='default value here' user-input-read variable_name
user-input-tui-read() {
	local target_variable_name="$1"
	if [[ -z $"target_variable_name" ]]; then
		errcho 'no target variable'
	fi

	local prompt=${question:-user input}
	if [[ -n "${default:-}" ]]; then
		if [[ -z "$prompt" ]]; then
			prompt="$prompt "
		fi
		prompt="$prompt [$default]"
	fi
	if [[ -n "$prompt" ]]; then
		prompt="$prompt: "
	fi	
	echo -n "$prompt"


	local result
	read result

	if [[ -z "$result" ]]; then
		result="${default:-}"
	fi

	printf -v "$target_variable_name" '%s' "$result"
}

# fun: question='input some value' default='default value here' title='window title' user-input-read variable_name
user-input-gui-read() {
	local target_variable_name="$1"
	if [[ -z $"target_variable_name" ]]; then
		errcho 'no target variable'
	fi

	local result
	if installed yad; then
		result=`yad --center --width 500 --entry --title "${title:-user input}" --text "${question:-value}" --entry-text="${default:-}"`
	elif installed zenity; then
		result=`zenity       --width 500 --entry --title "${title:-user input}" --text "${question:-value}" --entry-text="${default:-}"`
	else
		errcho 'neither yad nor zenity installed'
	fi

	printf -v "$target_variable_name" '%s' "$result"
}
