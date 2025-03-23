#!/bin/bash

make_directory() {
  local folders=("resouces" "posts" "tags" "posts-published" "posts-draft" "posts-new" "assets" "assets/images" "assets/fonts" "assets/css" "assets/js" "assets/etc")

  for folder in "${folders[@]}"; do
      if [ ! -d "$folder" ]; then
          mkdir "$folder"
      fi
  done

  echo -e "\033[0;34m*\033[0m Create directories"
}

make_directory
