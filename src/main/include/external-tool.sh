
external-tool-run() {
	local tool="$1"
	shift
	if external-tool-available "$tool"; then
		"$tool" "$@"
		return $?
	else
		errcho "required program $tool was not found"
		return 1
	fi
}

# fun: executable-available nano
# txt: check given program launchable
function external-tool-available() {
	type "$1" > /dev/null 2>&1
	return $?
}

# fun: find-available-executable exe1 ext2 .. exeN
function external-tool-select() {
	local all_args="$@"
	while [[ -n "${1:-}" ]]; do
		if external-tool-available "$1"; then
			echo "$1"
			return
		fi
		shift 1
	done
	errcho "external tools not found among $all_args"
	return 1
}