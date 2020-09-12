


function file-editor-find() {
	if is-interactive; then
		if [[ -n "${EDITOR:-}" ]]; then
			echo "$EDITOR" 
		else
			external-tool-select nano editor vi
		fi
	else
		external-tool-select code gedit kate subl
	fi
}

# fun: edit file.txt
function file-editor-run() {
	"$(file-editor-find)" "$1"
}