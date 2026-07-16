#!/usr/bin/env sh
set -e

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

termcmd="kitty --class=filechooser --title=Yazi-FileChooser -e"

cmd="yazi"

if [ "$save" = "1" ]; then
    set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
    set -- --chooser-file="$out" --cwd-file="$out.1" "$path"
else
    set -- --chooser-file="$out" "$path"
fi

# Escape and run
command="$termcmd $cmd"
for arg in "$@"; do
    escaped=$(printf '%s' "$arg" | sed 's/"/\\"/g')
    command="$command \"$escaped\""
done

sh -c "$command"

# Handle directory selection (Yazi writes cwd on quit)
if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out.1" ]; then
        cat "$out.1" > "$out"
    fi
    rm -f "$out.1"
fi
