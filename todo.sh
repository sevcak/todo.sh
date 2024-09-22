#!/bin/bash

# Read multi-line value from a config file
get_config_value() {
    local key="$1"
    local filename="$2"
    local in_value=0
    local value=""

    while IFS= read -r line; do
        # If line starts with the key and '=', capture the value
        if [[ "$line" =~ ^$key= ]]; then
            value="${line#*=}"      # Get the value after '='
            value="${value%\"}"     # Remove trailing quote (if present)
            value="${value#\"}"     # Remove leading quote (if present)
            in_value=1
        elif [[ $in_value -eq 1 ]]; then
            # Stop reading if we hit a new key or an empty line
            if [[ "$line" =~ ^[A-Za-z_]+= ]] || [[ -z "$line" ]]; then
                break
            fi
            # Append new lines to the value (for multi-line values)
            value="$value"$'\n'"$line"
        fi
    done < "$filename"

    value="${value%\"}"     # Remove trailing quote (if present)

    # Print the final value
    echo "$value"
}

DATE=$(date +"%Y-%m-%d")
CONFIG_FILENAME="./todo.config"

# Create config file if it doesn't exist
if [ ! -f "$CONFIG_FILENAME" ]; then
    echo "Config file not found, creating default config at $CONFIG_FILENAME."
    touch "$CONFIG_FILENAME"

    DEFAULT_TODO_DIR="./"
    DEFAULT_FILENAME="todo.md"
    DEFAULT_TEMPLATE='# TODO: (${DATE})
    [] Let the cat out of the bag'
    DEFAULT_DATE_IN_FILENAME="1"

    # Write default config to the file
    echo "TODO_DIR=\"$DEFAULT_TODO_DIR\"" >> "$CONFIG_FILENAME"
    echo "FILENAME=\"$DEFAULT_FILENAME\"" >> "$CONFIG_FILENAME"
    echo "DATE_IN_FILENAME=\"$DEFAULT_DATE_IN_FILENAME\"" >> "$CONFIG_FILENAME"
    echo "TEMPLATE=\"$DEFAULT_TEMPLATE\"" >> "$CONFIG_FILENAME"
fi

# Load config
while IFS='=' read -r KEY VALUE; do
    # Remove surrounding quotes from VALUE
    VALUE=$( echo "$VALUE" | sed 's/^"\(.*\)"$/\1/' )

    case "${KEY}" in
        "FILENAME")
            if [ -z "$FILENAME" ]; then
                FILENAME="$VALUE"
            else
                FILENAME="${VALUE}_${FILENAME}"
            fi
            ;;
        "TODO_DIR")
            TODO_DIR="$VALUE"
            ;;
        "DATE_IN_FILENAME")
            DATE_IN_FILENAME="$VALUE"
            ;;
    esac
done < "$CONFIG_FILENAME"

# Append date to filename if required
if [ "1" -eq "$DATE_IN_FILENAME" ]; then
    # Check if the filename has an extension
    if [[ "$FILENAME" == *.* ]]; then
        # Separate the base name and extension
        BASENAME="${FILENAME%.*}"
        EXTENSION="${FILENAME##*.}"

        # Append the date before the extension
        FILENAME="${BASENAME}_${DATE}.${EXTENSION}"
    else
        # If there's no extension, just append the date to the filename
        FILENAME="${FILENAME}_${DATE}"
    fi
fi

# Prepend target directory to filename if specified
if ! [ -z "$TODO_DIR" ]; then
    TODO_DIR=${TODO_DIR//\~/$HOME}

    FILENAME="${TODO_DIR}/${FILENAME}"
fi

# Create the target file if it doesn't already exist
if ! [ -f "$FILENAME" ]; then
    TEMPLATE="$( get_config_value "TEMPLATE" "${CONFIG_FILENAME}" )"

    # Replace ${DATE} occurrences
    TEMPLATE="${TEMPLATE//\$\{DATE\}/$DATE}"

    echo -e "$TEMPLATE" > "$FILENAME"
fi

# Open the file
${EDITOR:-nano} ${FILENAME}
