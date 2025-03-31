#!/bin/bash

FILE="test1.md"

ORIGIN_MD=""
NEW_HTML=""

# markdown line -> html tag
# $1: markdown line
# $2: html tag
# return: tagged string
wrap_with_tag() {
  local line=$1
  local tag=$2
  
  echo "<$tag>$line</$tag>"
}

# strap
# strap side whitespace
# 4 space = 1 tab = 1 indent level
# $1: markdown line
# return: indent level, strapped line
strap() {
  local line=$1
  local level="0"

  local leading_spaces=$(echo -n "$line" | grep -o ' ' | wc -l)
  level=$(( leading_spaces / 4 ))

# FIXME
# escape: \\ \. \| \# \! \* \+ \- \_ \( \{ \[ \< \`
# this line level is 3
  
  echo "$level" "$line"
}

# parser
# detect which tag is right one
# $1: markdown line
# return: tag string
parser() {
  local line=$1
  local tag="p"
  # TODO
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

  read -r indent strapped_line < <(strap "$line")
  
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
