# fun: debug some message text
# txt: print debug message if DEBUG is defined
debug() {
    test "${DEBUG:-}" == true && echo "DEBUG: $@" 1>&2 || true
    # >&2 echo goes to err
}