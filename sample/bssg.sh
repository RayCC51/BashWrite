#!/bin/bash
start_time=$(date +%s%N)

### Edit these settings.
BLOG_NAME="bssg blog"
AUTHOR_NAME="name"
BASE_URL="localhost:8080/"

LANG="en"

# If you don't know what you're doing,
# do not edit the code below.

# script info
_SCRIPT_NAME="Bash static site generator"
_SCRIPT_VERSION="0.6"
_SCRIPT_FILE_NAME="bssg.sh"
_SCRIPT_SITE="https://github.com/raycc51/bssg"

# echo colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# Some variables for scripting
FILELIST=""
FILESTATUS=""
CONTENTS=""
RESULTS=""
NEW_PATH=""
TITLE=""
DESCRIPTION=""
DATE=""
LASTMOD=""
TAGS=""
DRAFT=""

reset_var() {
  FILESTATUS=""
  CONTENTS=""
  RESULTS=""
  NEW_PATH=""
  TITLE=""
  DESCRIPTION=""
  DATE=""
  LASTMOD=""
  TAGS=""
  DRAFT=""
}

# Make style.css
make_style_css() {
  echo 'html{padding:0;margin:0;}' > style.css
}

# Make html that comes Before the CONTENS
make_before() {
  # Remove slash in BASE_URL
  if [[ "$BASE_URL" == */ ]]; then
    BASE_URL="${BASE_URL%/}"
  fi

  local OUTPUT="<!DOCTYPE html>
<html lang=$LANG>
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <meta name=\"author\" content=\"$AUTHOR_NAME\">
  <meta name=\"description\" content=\"$DESCRIPTION\">

  <meta property=\"og:title\" content=\"$TITLE\">
  <meta property=\"og:description\" content=\"$DESCRIPTION\">
  <meta property=\"og:url\" content=\"$BASE_URL${NEW_PATH:1}\">
  <meta name=\"twitter:card\" content=\"summary\">
  <meta name=\"twitter:title\" content=\"$TITLE\">
  <meta name=\"twitter:description\" content=\"$DESCRIPTION\">
  
  <title>$TITLE</title>
  <link rel=\"stylesheet\" href=\"/styles.css\">
</head>
<body>
  <header>
    <h3><a href=\"$BASE_URL\">$BLOG_NAME</a></h3>
    <nav>
      <ul>
        <li><a href=\"$BASE_URL/posts/\">Posts</a></li>
        <li><a href=\"$BASE_URL/tags/\">Tags</a></li>
      </ul>
    </nav>
  </header>
  <article>
    <header>
      <h1>$TITLE</h1>
      <p>Written in $DATE</p>
"

  if [ -n "$LASTMOD" ]; then
    OUTPUT+="      <p>Updated in $LASTMOD</p>"
  fi
  
  if [ -n "$LASTMOD" ]; then
    OUTPUT+="      <p>Tags: $TAGS</p>"
  fi
  
  OUTPUT+="    </header>
    <main>"

  echo "$OUTPUT"
}

# Make html that comes After the CONTENTS
make_after() {
  echo "    </main>
    <footer>
      <p>Generated with $_SCRIPT_NAME</p>
    </footer>
  </article>
</body>"
}


# Markdown to HTML converter
md2html() {
# input
# MOD=$(cat "$1")
MOD="$1"

# escape < > &
MOD=$(echo "$MOD" | sed -E '
  s/&/\&amp;/g
  s/</\&lt;/g
  s/>/\&gt;/g
')

# 4 backtick codeblock
MOD=$(echo "$MOD" | sed -E '
  /^````/ {
    N
    s/````(.*)\n```/```\1\n\\`\\`\\`/
  }
  /^```$/ {
    N
    s/```\n````/\\`\\`\\`\n```/
  }
')

# codeblock
# escape markdown symbols temparely
MOD=$(echo "$MOD" | sed -E '
  /^```/ {
    :a
    N
    /```$/!ba
    s/```([a-zA-Z0-9_]+)?\n/<pre><code class="language-\1">\n/
    s/```/<\/code><\/pre>/
    s/ class="language-"//

    s/\\/\\\\/g
    s/\./\\\./g
    s/\|/\\\|/g
    s/#/\\#/g
    s/!/\\!/g
    s/\*/\\\*/g
    s/\+/\\\+/g
    s/-/\\-/g
    s/\(/\\\(/g
    s/\)/\\\)/g
    s/\{/\\\{/g
    s/\}/\\\}/g
    s/\[/\\\[/g
    s/\]/\\\]/g
    s/`/\\`/g
    
    s/~/\\~/g
    s/=/\\=/g
    s/\^/\\^/g
    
    s/&lt;/\\</g
    s/&gt;/\\>/g
    s/&amp;/&/g
  }
')

# fixing codeblock for p
MOD=$(echo "$MOD" | sed -E '
  /^<pre>/,/<\/pre>$/ {
    s/^/</
    s/$/>/
  }
')

# blockquote
BLOCKQUOTE() {
MOD=$(echo "$MOD" | sed -E '
  s/^&gt; (.*)/<blockquote>\n\1\n<\/blockquote>/
  /^&gt; *$/d
')

MOD=$(echo "$MOD" | sed -E '
  /^<\/blockquote>$/ {
    N
    /<\/blockquote>\n<blockquote>/d
  }
')
}

# indented blockquote
while echo "$MOD" | grep -q '^&gt;'; do
  BLOCKQUOTE
done

# h1 ~ h6
MOD=$(echo "$MOD" | sed -E '
  s/^# (.*)$/<h1>\1<\/h1>/
  s/^## (.*)$/<h2>\1<\/h2>/
  s/^### (.*)$/<h3>\1<\/h3>/
  s/^#### (.*)$/<h4>\1<\/h4>/
  s/^##### (.*)$/<h5>\1<\/h5>/
  s/^###### (.*)$/<h6>\1<\/h6>/
')

# heading with id
MOD=$(echo "$MOD" | sed -E '
  s/^<h([1-6])>(.*) \{# ?(.*)\}<\/h\1>$/<h\1 id="\3">\2<\/h\1>/
')

# hr
MOD=$(echo "$MOD" | sed -E '
  s/^[-*_]{3,}$/<hr>/
')

# footnote
MOD=$(echo "$MOD" | sed -E '
  s/^\[\^(.*)\]: /[<a class="footnote" id="footnote-\1" href="#fn-\1">\1<\/a>]: /
  
  s/\[\^([^]]+)\]/<sup><a class="footnote" id="fn-\1" href="#footnote-\1">\1<\/a><\/sup>/g
')

# bold italic code
MOD=$(echo "$MOD" | sed -E '
  s/\*\*\*(.*)\*\*\*/<strong><em>\1<\/em><\/strong>/g
  s/\*\*(.*)\*\*/<strong>\1<\/strong>/g
   s/([^\\]?)\*(.*[^\\])\*/\1<em>\2<\/em>/g
  
  s/``(.*)``/\\`\1\\`/g
  s/([^\\]?)`(.*[^\\])`/\1<code>\2<\/code>/g
')

  # s/~(.*)~/<sub>\1<\/sub>/g
  # s/\^(.*)\^/<sup>\1<\/sup>/g
# del, mark, sup, sub
MOD=$(echo "$MOD" | sed -E '
  s/~~(.*)~~/<del>\1<\/del>/g
  s/==(.*)==/<mark>\1<\/mark>/g
  

  s/([^\\]?)~(.*[^\\])~/\1<sub>\2<\/sub>/g
  s/([^\\]?)\^(.*[^\\])\^/\1<sup>\2<\/sup>/g
')

# img, a
MOD=$(echo "$MOD" | sed -E '
  s/!\[(.*)\]\((.*) "(.*)"\)/<img src="\2" alt="\1" title="\3">/g
  s/!\[(.*)\]\((.*)\)/<img src="\2" alt="\1">/g

  s/&lt;(.*)&gt;/<a href="\1">\1<\/a>/g
  s/\[(.*)\]\((.*) "(.*)"\)/<a href="\2" title="\3">\1<\/a>/g
  s/\[(.*)\]\((.*)\)/<a href="\2">\1<\/a>/g
')

# li
# for seperate ul and ol, use il tag for ol
MOD=$(echo "$MOD" | sed -E '
  s/^( {4}*)[-*+] (.*)/<ul>\n\1<li>\2<\/li>\n<\/ul>/
  
  s/^( {4}*)[0-9]+\. (.*)/<ol>\n\1<il>\2<\/il>\n<\/ol>/
')

# clean duplicated ul ol
MOD=$(echo "$MOD" | sed -E '
  /^<\/[uo]l>$/ {
    N
    /<\/[uo]l>\n<[uo]l>/d
  }
')

# indented ul ol
MOD=$(echo "$MOD" | sed -E '
  s/^    ( {4}*)(<li>.*)$/\1<li><ul>\n    \1\2\n\1<\/ul><\/li>/
  
  s/^    ( {4}*)(<il>.*)$/\1<il><ol>\n    \1\2\n\1<\/ol><\/il>/
')

# clean duplicated indented ul ol
MOD=$(echo "$MOD" | sed -E '
  /^( {4}*)<\/[uo]l><\/[il]{2}>$/ {
    N
    /^( {4}*)<\/[uo]l><\/[il]{2}>\n\1<[il]{2}><[uo]l>$/d
  }
')

# restore il to li
MOD=$(echo "$MOD" | sed -E '
  s/il>/li>/g
')

# checkbox
MOD=$(echo "$MOD" | sed -E '
  s/^<li>\[ \]/<li><input type="checkbox" disabled>/
  s/^<li>\[x\]/<li><input type="checkbox" checked disabled>/
')

# table tr
MOD=$(echo "$MOD" | sed -E '
  /^\|(.*\|)+$/ {
    s/^/<table>\n<tr>/ 
    s/$/<\/tr>\n<\/table>/
  }
')

# clean duplicated table
MOD=$(echo "$MOD" | sed -E '
  /^<\/table>$/ {
    N
    /^<\/table>\n<table>$/d
  }
')

# thead tbody seperator
MOD=$(echo "$MOD" | sed -E '
  s/^<tr>[|:-]+<\/tr>$/<\/thead>\n<tbody>/
')

# td
MOD=$(echo "$MOD" | sed -E '
  /^<tr>/ {
    s/^<tr>\|/<tr>\n    <td>/
    s/\|<\/tr>$/<\/td>\n<\/tr>/
    s/\|/<\/td>\n    <td>/g
  }
')

# thead tbody
MOD=$(echo "$MOD" | sed -E '
  s/^<table>$/<table>\n<thead>/
  s/^<\/table>$/<\/tbody>\n<\/table>/
')

# td -> th
MOD=$(echo "$MOD" | sed -E '
  /<thead>/,/<\/thead>/s/td>/th>/g
')

# p
MOD=$(echo "$MOD" | sed -E '
  s/^( *)([^< ].*)$/<p>\1\2<\/p>/
  s/^(.*[^>])$/<p>\1<\/p>/
  
  /<p> *<\/p>/d
  s/^<p> {4}+(.*)/<p class="indented-p">\1/
  s/  <\/p>$/<\/p>\n/
')

# fixing p in blockquote
MOD=$(echo "$MOD" | sed -E '
  /^<blockquote>$/,/^<\/blockquote>$/ {
    /^<p>/ {
      N
      s/<\/p>\n<p>/<\/p>\n\n<p>/
    }
  }
')

# p clean empty line, combine continuous p in single p
MOD=$(echo "$MOD" | sed -E '
  /^<p>/ {
    N
    /^<p> *$\n<\/p>$/d
  }
  /^<p>.*<\/p>$/ {
    :a
    N
    /^<p>.*<\/p>\n<p>.*<\/p>$/ {
      s/<\/p>\n<p>/\n/
    }
    ba
  }
')

# fixing codeblock for p
MOD=$(echo "$MOD" | sed -E '
  /^<<pre>/,/<\/pre>>$/ {
    s/^<//
    s/>$//
  }
')

# escape keys
MOD=$(echo "$MOD" | sed -E '
  s/\\\\/\\/g
  s/\\\./\./g
  s/\\\|/\|/g
  s/\\#/#/g
  s/\\!/!/g
  s/\\\*/\*/g
  s/\\\+/\+/g
  s/\\-/-/g
  s/\\\(/\(/g
  s/\\\)/\)/g
  s/\\\{/\{/g
  s/\\\}/\}/g
  s/\\\[/\[/g
  s/\\\]/\]/g
  s/\\`/`/g
  s/\\</\&lt;/g
  s/\\>/\&gt;/g

  s/\\`/`/g
  s/\\~/~/g
  s/\\=/=/g
  s/\\\^/^/g
')

# output
echo "$MOD"
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

# Make reusable resources.
# Resource: style.css
# If there is resources, then ignore.
make_resource() {
  [ -e "style.css" ] || make_style_css
  echo -e "$BLUE*$RESET Build resources"
}

# Make markdown file list
# 
# It contain: 
# string file path, yyyymmddhhmmss update date
make_list() {  
  FILELIST=$(find ./write/ -type f -name "*.md" -exec sh -c 'for file; do echo "$file $(date -d @"$(stat --format="%Y" "$file")" +%Y%m%d%H%M%S)"; done' sh {} +)
}

# Find new file
# 
# Below function get_file_stat can not detect removed file
# So compare filelist.txt and FILELIST, add new files lines in FILELIST tempareley
find_new_files() {
  local REMOVED_LINES=""
  
  while IFS=' ' read -r FILE_PATH UPDATED; do
    if ! echo "$FILELIST" | grep -qF "$FILE_PATH"; then    
      REMOVED_LINES="$(printf "%s\n%s 000" "$REMOVED_LINES" "$FILE_PATH")"
    fi
  done < "filelist.txt"

  FILELIST+="$REMOVED_LINES"
}

# Update new file list
#
# Remove removed file lines ends with 000
update_file_list() {
  FILELIST=$(echo "$FILELIST" | grep -v ' 000$')
  echo "$FILELIST" > "filelist.txt"
}

# File status
#
# Save file status in FILESTATUS
# Did markdown files are changed or removed?
# Status: "U"pdated, "N"ew, "R"emoved,  no "C"hange
# FILELIST has lastest file list
# filelist.txt has previous file list
# 
# $1: a file path from FILELIST
# $2: lastest updated date
get_file_stat() {
  local NEW="$1"
  local NEW_UPDATED="$2"
  
  local OLD_UPDATED=$(awk -v new="$NEW" -F' ' '$1 == new {print $2}' filelist.txt)

  if [ -z "$OLD_UPDATED" ]; then
    FILESTATUS="N"
  elif [[ "$NEW_UPDATED" -gt "$OLD_UPDATED" ]]; then
    FILESTATUS="U"
  elif [ "$NEW_UPDATED" = "000" ]; then
    FILESTATUS="R"
  else
    FILESTATUS="C"
  fi
}

# Remove file
#
# User remove markdown file, 
# then script remove html file, ...
#
# $1: Removed file path
remove_file() {
  local FILE_PATH="$1"
  
  NEW_PATH=${FILE_PATH/write/posts}
  NEW_PATH=${NEW_PATH/.md/.html}

  rm "$NEW_PATH"

  echo -e "  $RED+[Remove]$RESET $NEW_PATH"
}

# Find frontmatter and get data
frontmatter() {
  local FILE_PATH="$1"

  local FRONTMATTER=$(awk '
    BEGIN { part=0 }
    /^---/{ part++ }
    part==1 { print }
  ' "$FILE_PATH")

  CONTENTS=$(awk '
    BEGIN { part=0 }
    /^---/{ part++ }
    part==2 { print }
    part>2 { print }
  ' "$FILE_PATH" | sed '1d')

  TITLE=$(echo "$FRONTMATTER" | awk -F': ' '/^title:/{print $2}')
  DESCRIPTION=$(echo "$FRONTMATTER" | awk -F': ' '/^description:/{print $2}')
  DATE=$(echo "$FRONTMATTER" | awk -F': ' '/^date:/{print $2}')
  LASTMOD=$(echo "$FRONTMATTER" | awk -F': ' '/^lastmod:/{print $2}')
  TAGS=$(echo "$FRONTMATTER" | awk -F': ' '/^tags:/{print $2}')
  DRAFT=$(echo "$FRONTMATTER" | awk -F': ' '/^draft:/{print $2}')

  if [ -n DATE ]; then
    DATE="20${UPDATED:0:2}-${UPDATED:2:2}-${UPDATED:4:2}"
  fi
}

# Converting markdown files
#
# $1: file name with directory
# $2: updated date
converting() {
  local FILE_PATH="$1"
  local STATUS=""

  # Make directory
  NEW_PATH=${FILE_PATH/write/posts}
  NEW_PATH=${NEW_PATH/.md/.html}
  mkdir -p "$(dirname "$NEW_PATH")"

  # Convert markdown to html text
  RESULTS=$(md2html "$CONTENTS")

  # Save html text in html file
  make_before > $NEW_PATH
  echo "$RESULTS" >> $NEW_PATH
  make_after >> $NEW_PATH

  if [ "$FILESTATUS" = "N" ]; then
    STATUS="New"
  elif [ "$FILESTATUS" = "U" ]; then
    STATUS="Update"
  fi
  
  echo -e "  $BLUE+[$STATUS]$RESET $NEW_PATH"
}

# Command line help text
show_help() {
  echo -e "$GREEN$_SCRIPT_NAME$RESET
${BLUE}version${RESET}: $_SCRIPT_VERSION

${BLUE}Arguments${RESET}
  ${YELLOW}./${_SCRIPT_FILE_NAME} help${RESET}    Show this text.
  ${YELLOW}./${_SCRIPT_FILE_NAME} build${RESET}   Build website. "
}

# Main code
if [[ "$#" -eq 0 || "$1" == "help" || "$1" == "h" ]]; then
  show_help
elif [[ "$1" == "build" || "$1" == "b" ]]; then
  make_directory
  make_resource
  make_list
  find_new_files

  echo -e "$BLUE*$RESET Converting..."
  while IFS=' ' read -r FILE_PATH UPDATED; do
    reset_var
    get_file_stat $FILE_PATH $UPDATED

    if [[ "$FILESTATUS" = "U" || "$FILESTATUS" = "N" ]]; then
      
      frontmatter $FILE_PATH
      # If not  draft
      if [ "$DRAFT" != "true" ] && [ "$DRAFT" != "True" ] && [ "$DRAFT" != "TRUE" ] && [ "$DRAFT" != "1" ]; then
        converting $FILE_PATH
      fi
    elif [ "$FILESTATUS" = "R" ]; then
      remove_file "$FILE_PATH"
    fi
  done <<< "$FILELIST"

  update_file_list
  
  echo -e "Done in $YELLOW$(( ($(date +%s%N) - start_time) / 1000000 ))${RESET}ms!"
else
  echo -e "$RED! Invaild argument$RESET
$BLUE* Valid Arguments$RESET
  ${YELLOW}./$_SCRIPT_FILE_NAME help${RESET}
  ${YELLOW}./$_SCRIPT_FILE_NAME build${RESET}"
fi
