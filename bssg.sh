#!/bin/bash

### Edit these settings.
config() {
  blog_name="bssg blog"
  author_name="name"
  base_url="localhost:8080/"

  echo -e "\033[0;34m*\033[0m Load config"
}


# If you don't know what you're doing,
# do not touch the code below.

# Make structure.
make_directory() {
  local folders=("resouces" "posts" "tags" "posts-published" "posts-draft" "posts-new" "assets" "assets/images" "assets/fonts" "assets/css" "assets/js" "assets/etc")

  for folder in "${folders[@]}"; do
      if [ ! -d "$folder" ]; then
          mkdir "$folder"
      fi
  done

  echo -e "\033[0;34m*\033[0m Create directories"
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
    echo -e "\033[0;34m*\033[0m Build resources"
  elif [ "$1" == "rebuild" ]; then
    # Rebuild everything. 
    make_head_html
    make_header_html
    make_footer_html
    make_style_css
    echo -e "\033[0;34m*\033[0m Rebuild resources"
  else
    :
  fi
}

# Main code
if [ "$#" -eq 0 ]; then
  show_help
elif [[ "$1" == "build" || "$1" == "rebuild" ]]; then
  config
  make_directory
  make_resource "$1"
else
  echo -e "\033[0;31m! Invaild parameter\033[0m"
  echo -e "\033[0;34m! Valid Commands\033[0m"
  echo "  ./bssg.sh"
  echo "  ./bssg.sh build"
  echo "  ./bssg.sh rebuild"
fi
