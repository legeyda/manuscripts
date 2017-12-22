#!/usr/bin/env bash

USAGE="Usage:
    $0 dir1 dir2 dir2 -- command"

# show help if requested
if [ "x$1" == "x-h" -o "x$1" == "x-?" -o  "x$1" == "x--help" ]; then
	echo "Execute command in each subdirectory of current directory."
	echo "$USAGE"
	exit 0
fi

# assert arguments supplied
if [ "x$1" == "x"  ]; then
	echo "foreach: no input, '$0 -h' for help"
	echo "$USAGE"
	exit 1
fi

# parse dirs
DIRS=
while [ "x$1" != "x"  ]; do
	if [ "x$1" == "x--" ]; then
		shift;
		break;
	fi
	if [ "x$DIRS" != "x" -a "x$2" == "x" ]; then
		break;
	fi
	DIR="$1"
	# before starting commands check all folders exist
	if pushd "$DIR" > /dev/null ; then
		popd > /dev/null
	else
		echo "foreach: error entering $DIR, dry exiting"
		exit 3
	fi
DIRS="$DIRS
$DIR"
	shift;
done || exit $?

# if [[ -z "$DIRS" ]]; then
# 	if [[ -n "${FOREACH_DIRS:-}" ]]; then
# 		echo "$0" $FOREACH_DIRS -- "$@"
# 		exit $?
# 	else
# 		>&2 echo "no dirs sets"
# 		exit 1
# 	fi
# 	exit $?
# fi


# assert command is set
if [ "x$1" == "x"  ]; then
	echo "foreach: no command, '$0 -h' for help"
	echo "$USAGE"
	exit 2
fi

export COMMAND="$*"
echo "now ready to execute '$COMMAND' in subdirs"


test -n "${CURRENT_BASE_NAME:-}" && export SET_CURRENT_BASE_NAME=false || export SET_CURRENT_BASE_NAME=true
test -n "${CURRENT_FULL_NAME:-}" && export SET_CURRENT_FULL_NAME=false || export SET_CURRENT_FULL_NAME=true

# execute commands
echo "$DIRS" | while read DIR; do
	if [ "x$DIR" != "x"  ]; then
		if pushd "$DIR" > /dev/null ; then
			echo "======== entering $DIR ========"
			test true == ${SET_CURRENT_BASE_NAME} && export CURRENT_BASE_NAME=$(basename "$DIR")
			test true == ${SET_CURRENT_FULL_NAME} && export CURRENT_FULL_NAME=$(realpath .)

			if bash -c "$COMMAND" ; then
				echo -n
			else
				echo "foreach: got result code $?, exiting"
				exit 4
			fi
			popd > /dev/null
			echo
		else
			echo "foreach: error entering $DIR, exiting"
			exit 3
		fi
	fi
done
