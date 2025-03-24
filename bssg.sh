#!/bin/bash

### Edit these settings.
config() {
  blog_name="bssg blog"
  author_name="name"
  base_url="localhost:8080/"

  echo -e "$BLUE*$RESET Load config"
}


# If you don't know what you're doing,
# do not touch the code below.

# Command line help text
show_help() {
  echo -e "${GREEN}bash static site generator$RESET
${BLUE}version${RESET}: 0.2

${BLUE}Commands${RESET}
  ${YELLOW}./bssg.sh help${RESET}    Show this text.
  ${YELLOW}./bssg.sh build${RESET}   Build new markdown posts to html files. If you have completed the blog setup and only want to ${BLUE}publish new posts${RESET}, use this command.
  ${YELLOW}./bssg.sh rebuild${RESET} Rebuild site. If you ${BLUE}change anything other than posts${RESET}, such as settings or styles, you must rebuild for the changes to take effect.
"
}

# Make structure.
make_directory() {
  local folders=("resouces" "posts" "tags" "posts-published" "posts-draft" "posts-new" "assets" "assets/images" "assets/fonts" "assets/css" "assets/js" "assets/etc")

  for folder in "${folders[@]}"; do
      if [ ! -d "$folder" ]; then
          mkdir "$folder"
      fi
  done

  echo -e "$BLUE*$RESET Create directories"
}

# Make head.html
make_head_html() {
  :
}

# Make header.html
make_header_html() {
  :
}

# Make footer.html
make_footer_html() {
  :
}

# Make style.css
make_style_css() {
  :
}


# Make reusable resources.
# Resource: head.html, header.html, footer.html, style.css
# 
# $1 = build or rebuild
make_resource() {
  if [ "$1" == "build" ]; then
    # If there is no resources, then make them. 
    [ -e "head.html" ] || make_head_html
    [ -e "header.html" ] || make_header_html
    [ -e "footer.html" ] || make_footer_html
    [ -e "style.css" ] || make_style_css
    echo -e "$BLUE*$RESET Build resources"
  elif [ "$1" == "rebuild" ]; then
    # Rebuild everything. 
    make_head_html
    make_header_html
    make_footer_html
    make_style_css
    echo -e "$BLUE*$RESET Rebuild resources"
  else
    :
  fi
}

# echo colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# Main code
if [[ "$#" -eq 0 || "$1" == "help" ]]; then
  show_help
elif [[ "$1" == "build" || "$1" == "rebuild" ]]; then
  config
  make_directory
  make_resource "$1"
else
  echo -e "$RED! Invaild parameter$RESET
$BLUE* Valid Commands$RESET
  ${YELLOW}./bssg.sh help${RESET}
  ${YELLOW}./bssg.sh build${RESET}
  ${YELLOW}./bssg.sh rebuild${RESET}"
fi
