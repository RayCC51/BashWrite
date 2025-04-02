#!/bin/bash

FILE="syntax.md"

HTML_CONTENT=""

TEMP_TAG=""

# check char is tag
# $1 char
parser() {
  local char="$1"

  case $char in
    new_line)
      HTML_CONTENT+="\n"
      ;;
    \#)
      HTML_CONTENT+="<h1>"
      ;;
    *)
      HTML_CONTENT+="$char"
      ;;
  esac
}

# read a markdown file
while IFS= read -r line; do
  for (( i=0; i<${#line}; i++ )); do
    parser "${line:i:1}"
  done
  parser "new_line"
done < "$FILE"

printf "$HTML_CONTENT"
