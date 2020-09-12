# fun: debug some message text
# txt: print debug message if DEBUG is defined
debug() {
    test "${DEBUG:-} == true && echo "$@"
}