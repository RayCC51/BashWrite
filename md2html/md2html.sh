#!/bin/bash

FILE="syntax.md"
# FILE="frontmatter.md"
# FILE="test.md"

ORIGIN_MD=""
NEW_HTML=""

# this stack contain status of markdown line
# ex) ("p" "strong")
STATUS=()

# add new status
# $1: string new item
add_status() {
  STATUS+=("$1")
}

# get last element in status
# return: string last element
current_status() {
  echo "${STATUS[-1]}"
}

# remove last element
remove_status() {
  unset 'STATUS[-1]'
}

# markdown line -> html tag
# $1: markdown line
# $2: html tag
# return: tagged string
wrap_with_tag() {
  local line=$1
  local tag=$2
  
  echo "<$tag>$line</$tag>"
}

# get indent level
# strap front whitespace
# 4 space = 1 tab = 1 indent level
# $1: markdown line
# return: indent level, strapped line
get_indent_level() {
  local line=$1
  local level="0"
  
  local leading_spaces=$(echo -n "$line" | grep -o ' ' | head -n 1 | wc -c)
  
  level=$(( leading_spaces / 4 ))

# FIXME: $line is already strapped
  
  echo "$level" "$line"
}

# find markdown tag to html tag
# $1: single letter of markdown
# return: html tag
find_tag() {
  local md=$1
  local tag=""

  if [ "$md" = "#" ]; then
    echo "h1"
  elif [ "$md" = ">" ]; then
    echo "blockquote"
  else
    echo "p"
  fi
  # TODO
}

# parser
# detect which tag is right one
# $1: markdown line
# return: tag string
parser() {
  local line=$1
  local tag="p"

  local first_letter=${line:0:1}
  local remain_line=${line:1}

  tag=$(find_tag "$first_letter")
  
  echo $tag
}

# main convert
# $1: markdown line
# return: html line
convert() {
  local line="$1"
  
  local html_line=""
  local tag=""
  local indent=""

  read -r indent strapped_line < <(get_indent_level "$line")

  tag=$(parser "$strapped_line")
  html_line=$(wrap_with_tag "$strapped_line" $tag)

  echo $html_line
}

# read line by line
while IFS= read -r line
do
  if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*$ ]]; then
    # skip empty line
    echo "$(convert "$line")"
  fi
done < "$FILE"
