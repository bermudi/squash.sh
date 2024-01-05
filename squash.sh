#!/bin/bash

# This script "squashes" a directory, moving all files in subdirectories to the root of the specified directory
# and renaming them to include their original subdirectory paths, excluding the root directory name.
# Options: -v for verbose, -d to delete empty directories.

usage() {
    echo "Usage: $0 [-v] [-d] <path-to-directory>"
    echo "  -v  Verbose mode. Show files being moved."
    echo "  -d  Delete empty subdirectories after moving files."
}

VERBOSE=0
DELETE_DIRS=0

# Parse options
while getopts "vd" opt; do
  case $opt in
    v) VERBOSE=1 ;;
    d) DELETE_DIRS=1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2
       usage
       exit 1
      ;;
  esac
done

# Remove parsed options from arguments list
shift $((OPTIND-1))

# Check if the directory argument is provided
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# The first argument is the directory to squash
DIR_PATH="$1"

# Check if the provided directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

# Change to the provided directory
cd "$DIR_PATH"

# Find all files in subdirectories and loop through them
find . -mindepth 2 -type f | while read file; do
    # Extract relative path
    relative_path=${file#./}

    # Replace slashes with hyphens in the relative path
    newname=$(echo $relative_path | tr '/' '-')

    # Move and rename the file, only if newname is not empty
    if [ ! -z "$newname" ]; then
        if [ $VERBOSE -eq 1 ]; then
            echo "Moving $file to $newname"
        fi
        mv "$file" "$newname"
    fi
done

# If chosen, delete empty directories
if [ $DELETE_DIRS -eq 1 ]; then
    find . -mindepth 1 -type d -empty -delete
fi
