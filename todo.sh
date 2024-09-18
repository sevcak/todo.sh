#!/bin/bash

DATE=$( date +"%Y-%m-%d" )
FILENAME=$"todo_${DATE}.md"

TEMPLATE="# TODO: (${DATE})
[] Let the cat out of the bag"

if ! [ -f "$FILENAME" ]; then
        echo "$TEMPLATE" > "$FILENAME"
fi

${EDITOR} ${FILENAME}
