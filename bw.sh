#!/bin/bash
start_time=$(date +%s%N)


### Edit these configs.
BLOG_NAME="bashwrite blog"
AUTHOR_NAME="raycc"
BASE_URL="https://raycc51.github.io/BashWrite/"

### Your blog theme color. Write in hex code #rrggbb
MAIN_COLOR="#CAD926"

### <html lang="$LANG">
LANG="en"

### How many recent posts should be shown on the homepage.
### Set it to 0 to hide recent posts.
RECENT_POSTS_COUNT=5

### Write your profile in Markdown syntax.
### This paragraph will be included in the homepage of your blog.
### Be careful! You need to escape some letters: \\ \' \" \$
PROFILE="
# Welcome to sample blog

This blog source in [Github](https://github.com/RayCC51/BashWrite/tree/gh-pages)
"

### Write your own HTML code. 
### This variable will be includes inside the <html><head>Here!</head></html> in every html files.
### You can add your css or js in this line. 
CUSTOM_HTML_HEAD=""

#
#
# If you don't know what you're doing,
# do not edit the code below.
#
#

# script info
_SCRIPT_NAME='BashWrite'
_SCRIPT_VERSION='1.1.3'
_SCRIPT_FILE_NAME='bw.sh'
_SCRIPT_SITE='https://github.com/raycc51/bashwrite'

# echo colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# Some variables for scripting
ALL_POSTS=""
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
COUNT_CHANGE=0

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
  echo ":root{
  --main-theme: $MAIN_COLOR;
" > style.css

  echo '
  --background-color: #ffffff;
  --font-color: #272822;
  --gray: color-mix(in srgb, var(--font-color), var(--background-color) 30%);
  --code-bg: color-mix(in srgb, var(--main-theme), var(--background-color) 90%);
}
.dark {
  --background-color: #272822;
  --font-color: #cfcfce;
}

.dark a {color: #1E90FF;}
.dark a:visited {color: #9370DB;}
body {color: var(--font-color); background-color: var(--background-color); max-width: 900px; margin: 0 auto; padding: 0 1em;}
body > header {display: flex; justify-content: space-between; align-items: center; padding: 0 0.5em; border-bottom: 1px solid var(--main-theme);}
body > header h3 a, body > header h3 a:visited, .dark body > header h3 a {color: var(--main-theme) !important;}
body > header ul {display: flex;}
body > header li {list-style: none; margin-left: 1em;}
body > header a, body > header a:visited, .dark body > header a {text-decoration: none; color: var(--font-color) !important;}
body > footer {border-top: 1px solid var(--main-theme);}
article > header {border-bottom: 2px solid var(--main-theme);}
#meta-date, #meta-lastmod {color: var(--gray);}
pre {background-color: var(--code-bg); overflow-x: auto; padding: 0 0 1em 1em;}
code {background-color: var(--code-bg);}
figure {text-align: center; margin: 0 auto;}
figcaption {color: var(--gray);}
blockquote {border-left: 2px solid var(--main-theme); padding-left: 1em; margin-left: 2em; margin-right: 2em;}
.table-container {overflow-x: auto;}
th {border-bottom: 2px solid var(--main-theme);}
td {border-bottom: 1px solid var(--gray);}
.indented {text-indent: 30px;}
#toTop {position: fixed; bottom: 1em; right: 1em; width: 3em; height: 3em; background-color: var(--main-theme); color: white; border-radius: 50%; z-index: 5; text-decoration: none; text-align: center; line-height: 3em; opacity: 0.7;}
img {max-width: 95%;}
.recent-description {opacity: 0.8;}
.align-left {text-align: left;}
.align-right {text-align: right;}
.align-center {text-align: center;}
details {border-top: 1px solid var(--main-theme); border-bottom: 1px solid var(--main-theme);}
' >> style.css

  echo -e "  $BLUE+$RESET style.css"
}

# Make html that comes Before the CONTENS
make_before() {
  local OUTPUT="<!DOCTYPE html>
<html lang=\"$LANG\">
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
  <link rel=\"stylesheet\" href=\"$BASE_URL/style.css\">

  <script>
  if(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    document.documentElement.classList.add(\"dark\");
  }
  </script>

  $CUSTOM_HTML_HEAD
</head>
<body>
  <header>
    <h3><a href=\"$BASE_URL\">$BLOG_NAME</a></h3>
    <nav>
      <ul>
        <li><a href=\"$BASE_URL/all-posts.html\">Posts</a></li>
        <li><a href=\"$BASE_URL/all-tags.html\">Tags</a></li>
        <li><a href=\"$BASE_URL/rss.xml\">RSS</a></li>
      </ul>
    </nav>
  </header>
  <article>
    <header>
      <h1 id=\"meta-title\">$TITLE</h1>"

  if [ -n "$DATE" ]; then
    OUTPUT+="
      <p id=\"meta-date\">Written in <time>$DATE</time></p>"
  fi

  if [ -n "$LASTMOD" ]; then
    OUTPUT+="
      <p id=\"meta-lastmod\">Updated in <time>$LASTMOD</time></p>"
  fi
  
  if [ -n "$TAGS" ]; then
    tags_html=""

    for tag in $TAGS; do
        tags_html+="<a href=\"$BASE_URL/tags/${tag}.html\">${tag}</a> "
    done
    
    OUTPUT+="
      <p id=\"meta-tags\">Tags: $tags_html</p>"
  fi
  
  OUTPUT+="
    </header>
    <main>"

  echo "$OUTPUT"
}

# Make html that comes After the CONTENTS
make_after() {
  echo "
    </main>
  </article>
  <footer>
    <p>© $(date +%Y) ${AUTHOR_NAME}</p>
    <p>Generated with <a href=\"${_SCRIPT_SITE}\">${_SCRIPT_NAME}</a></p>
  </footer>
  <a href=\"#\" id=\"toTop\">&#x2B06;</a>
</body>"
}


# Fix config that user make mistake
fix_config() {
  # Check THEME_COLOR is hex code color
  if [[ ! "$MAIN_COLOR" =~ ^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$ ]]; then
    echo -e "$RED!$RESET THEME_COLOR is not hex code color!"
    echo "  $_SCRIPT_FILE_NAME line:11"
    MAIN_COLOR="#CAD926"
  fi
  
  # Remove slash in BASE_URL
  if [[ "$BASE_URL" == */ ]]; then
    BASE_URL="${BASE_URL%/}"
  fi

  # Add https in BASE_URL
  if [[ "$BASE_URL" != http* ]]; then
    BASE_URL="http://$BASE_URL"
  fi

  # Fixing file/folder name with whitezspace
  find . -depth -name "* *" | while IFS= read -r file; do
    new_name=$(echo "$file" | tr ' ' '_')
      
    mv "$file" "$new_name"
  done
  
}

# Markdown to HTML converter
md2html() {
# input
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
    s/^:/\\:/
    
    s/&lt;/\\</g
    s/&gt;/\\>/g
  }
')

# fixing codeblock for p
MOD=$(echo "$MOD" | sed -E '
  /^<pre>/,/<\/pre>$/ {
    s/^/</
    s/$/>/
  }
')

# details summary html
MOD=$(echo "$MOD" | sed -E '
  s/&lt;(\/?details)&gt;/<\1>/
  s/&lt;(\/?summary)&gt;/<\1>/g
')

# html comment
MOD=$(echo "$MOD" | sed -E '
  s/&lt;(!-- .* --)&gt;/<\1>/
')

# html br
MOD=$(echo "$MOD" | sed -E '
  s/&lt;(br)&gt;/<\1>/
')

# blockquote
BLOCKQUOTE() {
  MOD=$(echo "$MOD" | sed -E '
  s/^&gt; ?(.*)/<blockquote>\n\1\n<\/blockquote>/
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
  s/^<h([1-6])>(.*) ?\{# ?(.*)\}<\/h\1>$/<h\1 id="\3"><a href="#\3">\2<\/a> 🔗<\/h\1>/
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
  s/(^|[^\\*])\*([^*]*[^\\*])\*([^*]|$)/\1<em>\2<\/em>\3/g
   s/(^|[^\\*])\*\*([^*]*[^\\*])\*\*([^*]|$)/\1<strong>\2<\/strong>\3/g
   s/(^|[^\\])\*\*\*([^*]*[^\\*])\*\*\*/\1<strong><em>\2<\/em><\/strong>/g
  s/(^|[^\\*])\*([^*]*[^\\*])\*([^*]|$)/\1<em>\2<\/em>\3/g
   s/(^|[^\\*])\*\*([^*]*[^\\*])\*\*([^*]|$)/\1<strong>\2<\/strong>\3/g
  
  s/``(.*)``/\\`\1\\`/g
  s/(^|[^\\])`([^`]*[^\\])`/\1<code>\2<\/code>/g
')

# del, mark, sup, sub
MOD=$(echo "$MOD" | sed -E '
  s/~~(.*)~~/<del>\1<\/del>/g
  s/==(.*)==/<mark>\1<\/mark>/g
  s/~(.*)~/<sub>\1<\/sub>/g
  s/([^\\]?)\^(.*[^\\])\^/\1<sup>\2<\/sup>/g
')

# img, a
MOD=$(echo "$MOD" | sed -E '
  s/!\[(.*)\]\((.*) "(.*)"\)/<figure>\n  <img src="\2" alt="\1" title="\3">\n  <figcaption>\1<\/figcaption>\n<\/figure>/g
  s/!\[(.*)\]\((.*)\)/<figure>\n  <img src="\2" alt="\1">\n  <figcaption>\1<\/figcaption>\n<\/figure>/g

  s/&lt;(.*)&gt;/<a href="\1">\1<\/a>/g
  s/\[(.*)\]\((.*) "(.*)"\)/<a href="\2" title="\3">\1<\/a>/g
  s/\[(.*)\]\((.*)\)/<a href="\2">\1<\/a>/g
')

# ul ol li
LI() {
MOD=$(echo "$MOD" | sed -E '
  /^[-+*] / {
    i\<ul>
    $ a\<\/ul>
    :a
    n
    $ a\<\/ul>
    /^[-+*] |^ {4}/ ba
    i\<\/ul>
  }
')

MOD=$(echo "$MOD" | sed -E '
  /^[0-9]+\. / {
    i\<ol>
    $ a\<\/ol>
    :a
    n
    $ a\<\/ol>
    /^[0-9]+\. |^ {4}/ ba
    i\<\/ol>
  }
')

MOD=$(echo "$MOD" | sed -E '
  /^<ul>$/,/^<\/ul>$/ {
    s/^[-+*] (.*)$/<li>\1<\/li>/
    s/^ {4}(.*)/<li>\n\1\n<\/li>/
  }
  /^<ol>$/,/^<\/ol>$/ {
    s/^[0-9]+\. (.*)$/<li>\1<\/li>/
    s/^ {4}(.*)/<li>\n\1\n<\/li>/
  }
')

MOD=$(echo "$MOD" | sed -E '
  /^<\/li>$/ {
    N
    /^<\/li>\n<li>$/d
  }
')
}

while echo "$MOD" | grep -qE '^[-+*] |^[0-9]+\. '; do
  LI
done

MOD=$(echo "$MOD" | sed -E '
  /^<[uo]l>$/,/^<\/[uo]l>$/ {
    /<\/li>$/ {
      :a
      N
      /<\/li>$/ ba
      s/<\/li>\n<li>$//
    }
  }
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
  /^<table>$/,/^<\/table>$/ {
    s/^<tr>[|:-]+<\/tr>$/<\/thead>\n<tbody>/
  }
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
  /^<table>$/ a\<thead>
  /^<\/table>$/ i\<\/tbody>
')

# td -> th
MOD=$(echo "$MOD" | sed -E '
  /<thead>/,/<\/thead>/s/td>/th>/g
')

# dt
MOD=$(echo "$MOD" | sed -E '
  /^[^:]/ {
    N
    s/^([^:].*)\n(: .*)/<dl>\n    <dt>\1<\/dt>\n<\/dl>\n\2/
  }
')

# dl dd
MOD=$(echo "$MOD" | sed -E '
  s/^: (.*)$/<dl>\n    <dd>\1<\/dd>\n<\/dl>/
')

# clean dl
MOD=$(echo "$MOD" | sed -E '
  /^<\/dl>$/ {
    N
    /<\/dl>\n<dl>/d
  }
')

MOD=$(echo "$MOD" | sed -E '
  /^<\/dl>$/ {
    N
    N
    /<\/dl>\n\n<dl>/d
  }
')

# p
MOD=$(echo "$MOD" | sed -E '
  s/^( *)([^< ].*)$/<p>\1\2<\/p>/
  s/^(.*[^>])$/<p>\1<\/p>/
  
  s/^(<(em|strong|code|del|sup|sub|mark).*)$/<p>\1<\/p>/

  /<p> *<\/p>/d
  s/^<p> {4}+(.*)/<p class="indented">\1/
  s/  <\/p>$/<\/p>\n/
')

# combine continuous p
MOD=$(echo "$MOD" | sed -E '
  /^<p>.*<\/p>$/ {
    :a
    N
    /<\/p>\n<p>/ {
      s/<\/p>\n<p>/\n/
      ba
    }
  }
')

# fixing codeblock for p
MOD=$(echo "$MOD" | sed -E '
  /^<<pre>/,/<\/pre>>$/ {
    s/^<//
    s/>$//
  }
')

# return escape keys
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
  s/^\\:/:/
')

# output
echo "$MOD"
}



# Make folder structure.
make_directory() {
  local folders=("posts" "tags" "write" "assets" "checksum")

  for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
      mkdir "$folder"
    fi
  done

  # Copy taglist.txt for find diffrence. 
  if [[ -e ./checksum/taglist.txt ]]; then
    cp ./checksum/taglist.txt taglist-old.txt
  else
    touch ./checksum/taglist.txt
    touch taglist-old.txt
  fi  
}

# Make robots.txt
make_robots_txt() {
  echo "User-agent: *
Disallow:" >> robots.txt

  echo -e "  $BLUE+$RESET robots.txt"
}

# Make sitemap.xml
make_sitemap_xml() {
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap-image/1.1\">

<url>
  <loc>$BASE_URL</loc>
  <lastmod>$(date +"%Y-%m-%d")</lastmod>
  <changefreq>daily</changefreq>
  <priority>1.0</priority>
</url>

<url>
  <loc>$BASE_URL/all-posts.html</loc>
  <lastmod>$(date +"%Y-%m-%d")</lastmod>
  <changefreq>daily</changefreq>
  <priority>0.8</priority>
</url>

<url>
  <loc>$BASE_URL/all-tags.html</loc>
  <lastmod>$(date +"%Y-%m-%d")</lastmod>
  <changefreq>daily</changefreq>
  <priority>0.4</priority>
</url>

<url>
  <loc>$BASE_URL/posts/</loc>
  <lastmod>$(date +"%Y-%m-%d")</lastmod>
  <changefreq>daily</changefreq>
  <priority>0.9</priority>
</url>

<url>
  <loc>$BASE_URL/tags/</loc>
  <lastmod>$(date +"%Y-%m-%d")</lastmod>
  <changefreq>daily</changefreq>
  <priority>0.3</priority>
</url>

</urlset>" > sitemap.xml

  echo -e "  $BLUE+$RESET sitemap.xml"
}

# Make 404 not found page
make_404_html() {
  reset_var
  TITLE="404 Page not found"
  DESCRIPTION="404"
  NEW_PATH="./404.html"

  make_before > 404.html
  echo "<p>404 404 404 404</p>" >> 404.html
  make_after >> 404.html

  echo -e "  $BLUE+$RESET 404.html"
}

# Make markdown file list
# 
# checksum file_size file_path
# For removed files, temparaly set the checksum as 000
make_list() {
  local new='./temp_cksum_md.txt'
  local old='./checksum/cksum_md.txt'

  find ./write/ -type f -name "*.md" -exec cksum {} \; > $new

  if [ ! -e $old ]; then
    touch $old
  else
    local removed_md=$(grep -Fxv -f $new $old)
    local temp_removed=''

    if [ -n "$removed_md" ]; then
      while IFS=' ' read -r checksum file_size file_path; do
        temp_removed=$(printf "%s\n" "$temp_removed" "000 $file_size $file_path")
      done <<< "$removed_md"

      echo "$temp_removed" >> $new
    fi
  fi
}

# Update new file list
#
# Remove removed file lines starts with 000
update_file_list() {  
  grep -v '^000 ' ./temp_cksum_md.txt > ./checksum/cksum_md.txt
  rm ./temp_cksum_md.txt
}

# Update taglist.txt
#
# taglist.txt has lines like
#   tag_name html_link_1 html_link_2 ...
# Each lines start with tag name.
# Each links are seperated by whitespace.
# Tags are all lowercase
# 
# $1: TAGS(tags are seperated by whitespce)
update_tags_list() {
  local TAGS="$1"
  local FILE="./checksum/taglist.txt"
  local tag_line=""
  
  # Make taglist.txt
  if [ ! -f "$FILE" ]; then
    touch "$FILE"
  fi

  # Remove useless whitespace. Change to lowercase 
  TAGS=$(echo "$TAGS" | xargs | tr '[:upper:]' '[:lower:]')
  
  for tag in $TAGS; do 
  
    tag_line=$(grep "^$tag " "$FILE")

    if [ -z "$tag_line" ]; then
      # Add a new tag. 
      echo "$tag $NEW_PATH" >> "$FILE"
    elif [[ "$tag_line" != *"$NEW_PATH"* ]]; then
      # Add a path in existing tag. 
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # mac os
        sed -i '' "/^$tag / s|$| $NEW_PATH|" "$FILE"
      else
        # linux
        sed -i "/^$tag / s|$| $NEW_PATH|" "$FILE"
      fi
    fi
  done

  # Remove old tag. 
  local pattern='^'
  pattern+=$(echo "$TAGS" | sed 's/ /\\|^/g')

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # mac os
    # Remove old tag
    sed -i '' "/$pattern /! s| $NEW_PATH||g" "$FILE"
    # Remove empty tag. 
    sed -i '' '/^[^ ]*$/d' "$FILE"
  else
    # linux
    sed -i "/$pattern /! s| $NEW_PATH||g" "$FILE"
    sed -i '/^[^ ]*$/d' "$FILE"
  fi
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
# return: FILESTATUS
get_file_stat() {
  local file_path="$1"
  local file_checksum="$2"

  local old_checksum=$(awk -v file="$file_path" -F' ' '$3 == file {print $1}' ./checksum/cksum_md.txt)

  if [ -z "$old_checksum" ]; then
    echo 'N'
  elif [[ "$file_checksum" == '000' ]]; then
    echo 'R'
  elif [[ "$file_checksum" != "$old_checksum" ]]; then
    echo 'U'
  else
    echo 'C'
  fi
}

# Remove file
#
# User remove markdown file, 
# then script remove html file, tag, and more. 
#
# $1: Removed file path
remove_file() {
  local FILE_PATH="$1"
  local taglist='./checksum/taglist.txt'
  
  rm "$NEW_PATH"

  # Remove tags
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # mac os
    sed -i '' -e "s| $NEW_PATH||g" $taglist
    sed -i '' '/^[^ ]*$/d' $taglist
  else
    # linux
    sed -i -e "s| $NEW_PATH||g" $taglist
    sed -i '/^[^ ]*$/d' $taglist
  fi

  echo -e "  $RED-[Remove]$RESET $NEW_PATH"
}

# Find frontmatter and get data
#
# $1: markdown file path
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

  if [ -z "$DATE" ]; then
    DATE=$(date +"%Y-%m-%d")
  fi
  
  if [ -z "$TITLE" ]; then
    TITLE="New post $DATE"
  fi

  # Fix <,> to &lt; &gt;
  if [ -n "$TITLE" ]; then
    TITLE=${TITLE//</\&lt;}
    TITLE=${TITLE//>/\&gt;}
  fi
  if [ -n "$DESCRIPTION" ]; then
    DESCRIPTION=${DESCRIPTION//</\&lt;}
    DESCRIPTION=${DESCRIPTION//>/\&gt;}
  fi
  if [ -n "$TAGS" ];then
    # Only allow alphabets, numbers and dash underscore in tags
    TAGS=$(echo "$TAGS" | sed 's/[^ a-zA-Z0-9_-]//g')
    # Remove duplicated tags
    TAGS=$(echo "$TAGS" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ')
  fi
}

# Converting markdown files
#
# $1: file name with directory
# $2: updated date
converting() {
  local FILE_PATH="$1"

  # Make directory
  mkdir -p "$(dirname "$NEW_PATH")"

  # Convert markdown to html text
  RESULTS=$(md2html "$CONTENTS")

  # Save html text in html file
  make_before > $NEW_PATH
  echo "$RESULTS" >> $NEW_PATH
  make_after >> $NEW_PATH

  local status=''
  case "$FILESTATUS" in
    N)
      status='New'
      ;;
    U)
      status='Update'
      ;;
    C)
      status='Rebuild'
      ;;
  esac
  
  echo -e "  $BLUE+[$status]$RESET $NEW_PATH"
}

# Convert link list to html format with group by year-month
#
# $1: string variable with format
#   date url title
# return: html string
group_list() {
  local ORIGIN="$1"
  local RESULT=""
  local TEMP_DATE=""

  # Sort by reverse chronicle
  ORIGIN=$(echo "$ORIGIN" | grep -v '^$' | sort -k1,1r)
  
  # Group the posts by year-month
  while IFS= read -r -a line; do
    DATE="${line[0]}"
    URL=$(echo "${line[1]}" | sed 's/index.html$//')
    TITLE="${line[@]:2}"
    
    if [ -z "$TEMP_DATE" ]; then
      TEMP_DATE="${DATE:0:7}"
    elif [ "$TEMP_DATE" != "${DATE:0:7}" ]; then
      RESULT+=$'\n'
      TEMP_DATE="${DATE:0:7}"
    fi
      RESULT+="$DATE $URL $TITLE"$'\n'
  done <<< "$ORIGIN"
    
  # Wraping with html tag
  RESULT=$(echo "$RESULT" | sed -E '
    s/^([0-9]{4}-[0-9]{2})(-[0-9]{2}) ([^ ]*) (.*)$/<li><time>\1<\/time><ul>\n<li><time>\1\2<\/time> <a href="\3">\4<\/a><\/li>\n<\/ul><\/li>/
  ')
  RESULT=$(echo "$RESULT" | sed -E '
    /^<\/ul><\/li>$/ {
      N
      /<\/ul><\/li>\n<li>.*<ul>/d
    }
  ')
  RESULT=$(echo "$RESULT" | sed -E '
    s/(href=".*\/)index.html">/\1">/
  ')
    
  echo "$RESULT"
}

# Make all-posts.html
#
# List of every posts link
make_all_posts_html() {
  local HTML_ALL_POSTS=""

  HTML_ALL_POSTS=$(group_list "$ALL_POSTS")
  
  reset_var
  TITLE="All Posts"
  DESCRIPTION="Every post links of $BLOG_NAME"
  NEW_PATH="./all-posts.html"

  make_before > all-posts.html
  {
    echo "<ul>"
    echo "$HTML_ALL_POSTS"
    echo "</ul>" 
  } >> all-posts.html
  make_after >> all-posts.html

  echo -e "  $BLUE+$RESET all-posts.html"
}

# Make all-tags.html
#
# Contain every tag page link in tags/
make_all_tags_html() {
  local HTML_ALL_TAGS=""

  # Find all tags and counts
  while IFS= read -r line; do
    first_word=$(echo "$line" | awk '{print $1}')
    count=$(( $(echo "$line" | wc -w) - 1 ))
      
    HTML_ALL_TAGS+="$first_word $count\n"
  done < ./checksum/taglist.txt

  # Sort tags by abc order
  HTML_ALL_TAGS=$(echo -e "$HTML_ALL_TAGS" | sort)

  # Wrapping with html tags
  HTML_ALL_TAGS=$(echo "$HTML_ALL_TAGS" | sed -E "
    s|^([^ ]*) ([0-9]*)$|<li><a href=\"$BASE_URL/tags/\1.html\">\1</a> (\2)</li>|
  ")

  reset_var
  TITLE="All Tags"
  DESCRIPTION="Every tags in $BLOG_NAME"
  NEW_PATH="./all-tags.html"

  make_before > all-tags.html
  {
    echo "<ul>"
    echo "$HTML_ALL_TAGS"
    echo "</ul>" 
  } >> all-tags.html
  make_after >> all-tags.html

  echo -e "  $BLUE+$RESET all-tags.html"
}

# Make every tag pages
make_tag_pages() {
  local tag=''
  local links=''
  local new='./checksum/taglist.txt'
  local old='taglist-old.txt'

  # Find removed tag
  local REMOVED_TAG=$(grep -Fxv -f $new $old)
  local remove_lines=''
  
  if [ -n "$REMOVED_TAG" ]; then
    while IFS= read -r line; do
      tag=$(echo "$line" | awk '{print $1}')
      rm "./tags/$tag.html"
      remove_lines="$(grep ">$tag</a>" all-tags.html)$'\n'"
    done <<< "$REMOVED_TAG"
  fi

  grep -Fvx -f <(echo "$remove_lines") all-tags.html > temp && mv temp all-tags.html

  # Find updated or added tag
  local UPDATED_TAG=$(grep -Fvx -f $old $new)
  local MD_PATH=""
  local HTML_ALL_POSTS=""
  reset_var

  if [ -n "$UPDATED_TAG" ]; then
    while IFS= read -r line; do
      tag=$(echo "$line" | awk '{print $1}')
      links=$(echo "$line" | cut -d' ' -f2-)
      HTML_ALL_POSTS=""

      for url in $links; do
        MD_PATH=${url/posts/write}
        MD_PATH=${MD_PATH/.html/.md}

        frontmatter "$MD_PATH"

        if [ "$DRAFT" != "true" ] && [ "$DRAFT" != "True" ] && [ "$DRAFT" != "TRUE" ] && [ "$DRAFT" != "1" ]; then
          url="$BASE_URL${url:1}"
          HTML_ALL_POSTS+="$DATE $url $TITLE"$'\n'
        fi
      done

      HTML_ALL_POSTS=$(group_list "$HTML_ALL_POSTS")

      reset_var
      TITLE="$tag"
      DESCRIPTION="$tag tag in $BLOG_NAME"
      NEW_PATH="./tags/$tag.html"
  
      make_before > "$NEW_PATH"
      {
        echo "<ul>"
        echo "$HTML_ALL_POSTS"
        echo "</ul>" 
      } >> "$NEW_PATH"
      make_after >> "$NEW_PATH"
    done <<< "$UPDATED_TAG"
  
    echo -e "  $BLUE+$RESET tags/*.html"
  fi
}

# Make rss.xml
#
# Using rss 2.0
make_rss_xml() {
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">

<channel>
  <title>$BLOG_NAME</title>
  <link>$BASE_URL</link>
  <description>$AUTHOR_NAME's blog</description>
  <language>$LANG</language>
  <pubDate>$(date -u +"%a, %d %b %Y %H:%M:%S +0000")</pubDate>
  <copyright>© $(date +%Y) $AUTHOR_NAME</copyright>
  <atom:link href=\"$BASE_URL/rss.xml\" rel=\"self\" type=\"application/rss+xml\" />
" > rss.xml

  local recent10=$(echo "$ALL_POSTS" | sort -r -k1,1 | head -n 10)
  local _url=''
  local _title=''
  local _path=''
  local rss_date=''
  local article=''

  # line = date url title
  while IFS= read -r line; do
    rss_date=$(date -d "$(echo "$line" | awk '{print $1}')" +"%a, %d %b %Y 00:00:00 GMT")
    _url=$(echo "$line" | awk '{print $2}')
    words=($line)
    _title="${words[@]:2}"
    _path=${_url/"$BASE_URL"/.}
    article=$(sed -n '/<main>/,/<\/main>/p' "$_path")

    echo "<item>
  <title>$_title</title>
  <link>$_url</link>
  <guid>$_url</guid>
  <description><![CDATA[
    $article
  ]]></description>
  <pubDate>$rss_date</pubDate>
</item>
" >> rss.xml
  done <<< "$recent10"

  echo "</channel>
</rss>
" >> rss.xml

  echo -e "  $BLUE+$RESET rss.xml"
}

# Make index.html
#
# It contains: PROFILE, resent posts
make_index_html() {
  if [ "$RECENT_POSTS_COUNT" -gt 0 ]; then
    local RECENT_POSTS=$(echo "$ALL_POSTS" | sort -r -k1,1 | head -n "$RECENT_POSTS_COUNT")
    local HTML_RECENT_POSTS=''

    if [ -n "$RECENT_POSTS" ]; then
      HTML_RECENT_POSTS="<hr>
<div id=\"recent-posts\">
  <h3>Recent posts</h3>
  <ul>"

    while IFS=' ' read -r _DATE _URL _TITLE; do
      _PATH=".$(echo "${_URL}" | awk -F"$BASE_URL" '{print $2}')"
      _DESCRIPTION=$(awk -F'"' '/description/{print $4; exit}' ${_PATH})
      _URL=$(echo "$_URL" | sed 's/index.html$//')

      HTML_RECENT_POSTS+="
<li>
  <p><time>${_DATE}</time> <a href=\"${_URL}\">${_TITLE}</a></p>
"
      if [ -n "$_DESCRIPTION" ]; then
        HTML_RECENT_POSTS+="  <p class=\"recent-description\">${_DESCRIPTION}</p>
"
      fi
      HTML_RECENT_POSTS+="</li>
"
    done <<< "$RECENT_POSTS"

    HTML_RECENT_POSTS+="
  </ul>
</div>"
    fi
  fi

  reset_var
  TITLE="$BLOG_NAME"
  DESCRIPTION="$AUTHOR_NAME's $BLOG_NAME"
  NEW_PATH="./index.html"

  make_before > "$NEW_PATH"
  echo "<div id=\"profile\">" >> index.html
  md2html "$PROFILE" >> "$NEW_PATH"
  echo "</div>" >> "$NEW_PATH"

  echo "$HTML_RECENT_POSTS" >> index.html

  make_after >> "$NEW_PATH"

  echo -e "  $BLUE+$RESET index.html"
}

# Copy assets in write/ to posts/
copy_assets() {
  local new='./temp_cksum_asset.txt'
  local prev='./checksum/cksum_asset.txt'

  if [ ! -e "$prev" ]; then
    touch "$prev"
  fi

  find ./write/ -type f ! -name "*.md" -exec cksum {} \; > $new

  # Find remoced assets and remove them
  local REMOVED_ASSET=$(grep -Fvx -f $new $prev)

  if [ -n "$REMOVED_ASSET" ]; then
    while IFS=' ' read -r checksum file_size file_path; do
    rm "$file_path"
    done <<< "$REMOVED_ASSET"
  fi

  # Find updated or added asset
  local NEW_ASSET=$(grep -Fvx -f $prev $new)
  local new_path=''

  if [ -n "$NEW_ASSET" ]; then
    while IFS=' ' read -r checksum file_size file_path; do
      new_path=$(echo "$file_path" | sed 's/^\.\/write/\.\/posts/')
      mkdir -p "$(dirname "$file_path")"
      cp "$file_path" "$new_path"
    done <<< "$NEW_ASSET"
  fi

  mv $new $prev

  if [[ -n "$REMOVED_ASSET" || -n "$NEW_ASSET" ]]; then
    echo -e "  $BLUE+$RESET Copy assets in write/ to posts/"
  fi
}

# Check build or rebuild
#
# Rebuild if this script is modified
build_rebuild() {
  local prev='./checksum/cksum_script.txt'
  local new=$(cksum "$_SCRIPT_FILE_NAME")
  
  if [ ! -e $prev ] || [[ "$new" != $(cat $prev) ]]; then
    echo "$new" > $prev
    echo 'rebuild'
  else
    echo 'build'
  fi
}

# Command line help text
show_help() {
  echo -e "$GREEN$_SCRIPT_NAME$RESET
${BLUE}version${RESET}: $_SCRIPT_VERSION
${BLUE}site${RESET}: $_SCRIPT_SITE

Commands: 
  ${YELLOW}./$_SCRIPT_FILE_NAME$ h{RESET}
      (h)elp. Show this dialog.
  ${YELLOW}./$_SCRIPT_FILE_NAME$ b{RESET}
      (b)uild. Build the blog. It automatically decides whether to update the post or create all files anew.

First to do:
  ${BLUE}1.$RESET Open $YELLOW$_SCRIPT_FILE_NAME$RESET and edit config. 
  ${BLUE}2.$RESET Create a markdown file in $YELLOW./write/$RESET
    - Markdown files should starts with frontmatter. 
    $YELLOW---
    title: New post
    description: Description of this post.
    date: 2025-02-05
    lastmod: 2025-05-02
    tags: tag1 tag2
    draft: false
    ---$RESET
    - [date] and [lastmod](last modified date) should be yyyy-mm-dd format. 
    - [tags] are seperated with whitespace. 
    - [description], [lastmod], [tags] and [draft] are option.
  ${BLUE}3.$RESET Run ${YELLOW}./$_SCRIPT_FILE_NAME b$RESET
  ${BLUE}4.$RESET Now your posts are in ${YELLOW}./posts/$RESET
"
}

# Main code
ARG="$1"
if [[ "$#" -eq 0 || "$ARG" == h* || "$ARG" == H* ]]; then
  show_help
elif [[ "$ARG" == b* || "$ARG" == r* || "$ARG" == B* || "$ARG" == R* ]]; then
  fix_config
  make_directory

  # Check this script is modified. 
  ARG=$(build_rebuild)

  echo -e "Run $GREEN$_SCRIPT_NAME$RESET $_SCRIPT_VERSION [$ARG]"
  
  make_list

  echo -e "$BLUE*$RESET Converting..."
  while IFS=' ' read -r checksum file_size file_path; do
    if [ -z $file_path ]; then
      continue
    fi
    
    reset_var
    FILESTATUS=$(get_file_stat "$file_path" "$checksum")

    NEW_PATH=${file_path/write/posts}
    NEW_PATH=${NEW_PATH/.md/.html}
    
    if [ "$FILESTATUS" = "R" ]; then
      remove_file "$file_path"
      COUNT_CHANGE=1
    else
      frontmatter "$file_path"

      # Check draft is false
      if [ "$DRAFT" != "true" ] && [ "$DRAFT" != "True" ] && [ "$DRAFT" != "TRUE" ] && [ "$DRAFT" != "1" ]; then
        # Update file list
        ALL_POSTS+="$DATE $BASE_URL${NEW_PATH:1} $TITLE"$'\n'

        # Update tags list
        if [ -n "$TAGS" ]; then
          update_tags_list "$TAGS"
        fi
        
        # Build new updated posts
        # Rebuild every posts
        if [[ "$FILESTATUS" = "U" || "$FILESTATUS" = "N" || ( "$FILESTATUS" = "C" && "$ARG" == r* ) ]]; then
          converting "$file_path"
          COUNT_CHANGE=1
        fi
      fi
    fi
  done < ./temp_cksum_md.txt

  if [[ "$COUNT_CHANGE" == 0 ]];then
    echo -e "  $BLUE*$RESET There is no changes!"
  else
    update_file_list

    echo -e "$BLUE*$RESET Make resources..."
    make_style_css
    make_robots_txt
    make_sitemap_xml
    make_404_html
    make_all_posts_html
    make_all_tags_html
    make_index_html
    make_rss_xml
    make_tag_pages 
  fi

  copy_assets
  rm taglist-old.txt
  
  echo -e "Done in $YELLOW$(( ($(date +%s%N) - start_time) / 1000000 ))${RESET}ms!"
else
  echo -e "$RED! Invaild argument$RESET
If you need help, $YELLOW./$_SCRIPT_FILE_NAME help$RESET "
fi
