#!/bin/bash

### Edit these settings.
BLOG_NAME="bssg blog"
AUTHOR_NAME="name"
BASE_URL="localhost:8080/"

LANG="en"

# script info
_SCRIPT_NAME="Bash static site generator"
_SCRIPT_VERSION="0.2"
_SCRIPT_FILE_NAME="bssg.sh"

# echo colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# If you don't know what you're doing,
# do not touch the code below.

# Command line help text
show_help() {
  echo -e "$GREEN$_SCRIPT_NAME$RESET
${BLUE}version${RESET}: $_SCRIPT_VERSION

${BLUE}Arguments${RESET}
  ${YELLOW}./${_SCRIPT_FILE_NAME} help${RESET}    Show this text.
  ${YELLOW}./${_SCRIPT_FILE_NAME} build${RESET}   Build new markdown posts to html files. If you have completed the blog setup and only want to ${BLUE}publish new posts${RESET}, use this command.
  ${YELLOW}./${_SCRIPT_FILE_NAME} rebuild${RESET} Rebuild site. If you ${BLUE}change anything other than posts${RESET}, such as settings or styles, you must rebuild for the changes to take effect.
"
}

# Make structure.
make_directory() {
  local folders=("resouces" "posts" "tags" "write" "assets" "assets/images" "assets/fonts" "assets/css" "assets/js" "assets/etc")

  for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
      mkdir "$folder"
    fi
  done

  echo -e "$BLUE*$RESET Create directories"
}

# Make head.html
make_head_html() {
  echo "<!DOCTYPE html>
<html lang=$LANG>
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>$BLOG_NAME</title>
  <link rel=\"stylesheet\" href=\"styles.css\">
</head>" > head.html
  echo -e "  $BLUE-$RESET Make ${YELLOW}head.html$RESET"
}

# Make header.html
make_header_html() {
  echo "<header>
  <h1>$BLOG_NAME</h1>
</header>" > header.html
  echo -e "  $BLUE-$RESET Make ${YELLOW}header.html$RESET"
}

# Make footer.html
make_footer_html() {
  echo "<footer>
  <p>
    Generated with $_SCRIPT_NAME
  </p>
</footer>" > footer.html
  echo -e "  $BLUE-$RESET Make ${YELLOW}footer.html$RESET"
}

# Make style.css
make_style_css() {
  echo 'html{padding:0;margin:0;}' > style.css
  echo -e "  $BLUE-$RESET Make ${YELLOW}style.css$RESET"
}

# Make reusable resources.
# Resource: head.html, header.html, footer.html, style.css
#
# $1 = build or rebuild
make_resource() {
  if [ "$1" == "build" ]; then
    # If there no resources, then make them.
    echo -e "$BLUE*$RESET Build resources"
    [ -e "head.html" ] || make_head_html
    [ -e "header.html" ] || make_header_html
    [ -e "footer.html" ] || make_footer_html
    [ -e "style.css" ] || make_style_css
  elif [ "$1" == "rebuild" ]; then
    # Rebuild everything.
    echo -e "$BLUE*$RESET Rebuild resources"
    make_head_html
    make_header_html
    make_footer_html
    make_style_css
  else
    :
  fi
}

# Main code
if [[ "$#" -eq 0 || "$1" == "help" ]]; then
  show_help
elif [[ "$1" == "build" || "$1" == "rebuild" ]]; then
  make_directory
  make_resource "$1"
else
  echo -e "$RED! Invaild argument$RESET
$BLUE* Valid Arguments$RESET
  ${YELLOW}./$_SCRIPT_FILE_NAME help${RESET}
  ${YELLOW}./$_SCRIPT_FILE_NAME build${RESET}
  ${YELLOW}./$_SCRIPT_FILE_NAME rebuild${RESET}"
fi
