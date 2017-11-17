#!/usr/bin/env bash


JOBS=4

#ps | grep " $OWNPID " | wc -l

export COMMAND="$*"

test -n "${CURRENT_BASE_NAME:-}" && export SET_CURRENT_BASE_NAME=false || export SET_CURRENT_BASE_NAME=true
test -n "${CURRENT_FULL_NAME:-}" && export SET_CURRENT_FULL_NAME=false || export SET_CURRENT_FULL_NAME=true
find . -maxdepth 1 -mindepth 1 -type d | while read DIR; do
	if [ -e "$DIR/.git" ]; then
		if pushd "$DIR" > /dev/null ; then
			echo -n "    $(basename $DIR): "
			test true == ${SET_CURRENT_BASE_NAME} && export CURRENT_BASE_NAME=$(basename "$DIR")
			test true == ${SET_CURRENT_FULL_NAME} && export CURRENT_FULL_NAME=$(realpath "$DIR")
			#COMMAND=$(echo "$COMMAND" | sed -e "s/{NAME}/$DIR/g;")

			if eval "$COMMAND" ; then
				echo -n
			else
				echo "foreach: got result code $?, exiting"
				exit 4
			fi
			popd > /dev/null
		else
			echo "foreach: error entering $DIR, exiting"
			exit 3
		fi
	fi
done
