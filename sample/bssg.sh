#!/bin/bash

### Edit these settings.
BLOG_NAME="bssg blog"
AUTHOR_NAME="name"
BASE_URL="localhost:8080/"

LANG="en"

# If you don't know what you're doing,
# do not touch the code below.

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

# Some variables for scripting
LASTBUILD=""

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

# Markdown to HTML converter
md2html() {
# input
MOD=$(cat "$1")

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

# Make head.html
make_head_html() {
  echo "<!DOCTYPE html>
<html lang=$LANG>
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>$BLOG_NAME</title>
  <link rel=\"stylesheet\" href=\"styles.css\">
</head>"
}

# Make header.html
make_header_html() {
  echo "<header>
  <h1>$BLOG_NAME</h1>
</header>"
}

# Make footer.html
make_footer_html() {
  echo "<footer>
  <p>
    Generated with $_SCRIPT_NAME
  </p>
</footer>"
}

# Make style.css
make_style_css() {
  echo 'html{padding:0;margin:0;}' > style.css
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
# It contain: yymmdd last build date, string file name, yymmdd update date
# seperated with a space
make_list() {
  date +%y%m%d > filelist.txt
  
  find ./write/ -type f -name "*.md" -exec sh -c 'for file; do echo "$file $(date -d @"$(stat --format="%Y" "$file")" +%y%m%d)"; done' sh {} + >> filelist.txt
}

# Converting markdown files
#
# $1: file name with directory
# $2: updated date
converting() {
  local NAME="$1"
  local UPDATED="$2"
}

# Main code
if [[ "$#" -eq 0 || "$1" == "help" ]]; then
  show_help
elif [[ "$1" == "build" ]]; then
  make_directory
  make_resource
  make_list

  # Do every files in filelist.txt
  {
    read LASTBUILD
    while IFS= read -r line; do
      converting $line
    done 
  } < "filelist.txt"
else
  echo -e "$RED! Invaild argument$RESET
$BLUE* Valid Arguments$RESET
  ${YELLOW}./$_SCRIPT_FILE_NAME help${RESET}
  ${YELLOW}./$_SCRIPT_FILE_NAME build${RESET}
  ${YELLOW}./$_SCRIPT_FILE_NAME rebuild${RESET}"
fi
