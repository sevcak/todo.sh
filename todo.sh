#!/bin/bash

DATE=$( date +"%Y-%m-%d" )
FILENAME=$"todo_${DATE}.md"

TEMPLATE="# TODO: (${DATE})
[] Let the cat out of the bag"

echo "$TEMPLATE" > "$FILENAME"

${EDITOR} ${FILENAME}
