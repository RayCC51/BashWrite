#!/bin/bash
start_time=$(date +%s%N)

# Find comments that start with ### and modify the variables below them.

### Default settings
BLOG_NAME="bashwrite blog"
AUTHOR_NAME="raycc"
BASE_URL="https://raycc51.github.io/BashWrite/"

### Your blog's main theme color. Write in hex code #rrggbb
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

You can find the source of this blog in the [Github](https://github.com/RayCC51/BashWrite/tree/gh-pages)
"

### Write your own HTML code. 
### This variable will be includes inside the 
# <html>
#   <head>
#     Here!
#   </head>
# </html> 
### in every html files.
### You can add your css or js. 
CUSTOM_HTML_HEAD=""

### Write your own HTML code.
### This will be includes inside the 
# <body>
#   <header></header>
#   <article>
#     <header></header>
#     <main></main>
#     Here!
#   </article>
#   <footer></footer>
# </body>
### only in the posts.
### You can add comments, banner, footer, or other things.
CUSTOM_HTML_ARTICLE_FOOTER=""


#
#
# If you don't know what you're doing,
# do not edit the code below.
#
#

# script info
_SCRIPT_NAME='BashWrite'
_SCRIPT_VERSION='1.2.0'
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
NEW_PATH=""
TITLE=""
DESCRIPTION=""
DATE=""
LASTMOD=""
TAGS=""
DRAFT=""
COUNT_CHANGE=0
PINNED_POSTS=''
PIN=''

reset_var() {
  FILESTATUS=""
  CONTENTS=""
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
body > header h3 a {color: var(--main-theme) !important;}
body > header ul {display: flex;}
body > header li {list-style: none; margin-left: 1em;}
body > header a {text-decoration: none; color: var(--font-color) !important;}
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
img, iframe {max-width: 95%;}
.recent-description {opacity: 0.8;}
.align-left {text-align: left;}
.align-right {text-align: right;}
.align-center {text-align: center;}
details {border-top: 1px solid var(--main-theme); border-bottom: 1px solid var(--main-theme);}
' >> style.css

  echo -e "  $BLUE+$RESET style.css"
}

# Make html that comes before the CONTENS
make_before() {
  local output="<!DOCTYPE html>
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
    output+="
      <p id=\"meta-date\">Written in <time>$DATE</time></p>"
  fi

  if [ -n "$LASTMOD" ]; then
    output+="
      <p id=\"meta-lastmod\">Updated in <time>$LASTMOD</time></p>"
  fi
  
  if [ -n "$TAGS" ]; then
    local tags_html=""

    for tag in $TAGS; do
        tags_html+="<a href=\"$BASE_URL/tags/${tag}.html\">${tag}</a> "
    done
    
    output+="
      <p id=\"meta-tags\">Tags: $tags_html</p>"
  fi
  
  output+="
    </header>
    <main>"

  echo "$output"
}

# Make html that comes After the CONTENTS
#
# $1 : If it is not empty, make_after includes the CUSTOM_HTML_ARTICLE_FOOTET variable.
make_after() {
  local html_footer=''
  
  if [ -n "$1" ]; then
    html_footer="<footer id=\"custom-html\">
      $CUSTOM_HTML_ARTICLE_FOOTER
    </footer>"
  fi
  
  echo "
    </main>
    $html_footer
  </article>
  <footer>
    <p>© $(date +%Y) ${AUTHOR_NAME}</p>
    <p>Generated by <a href=\"${_SCRIPT_SITE}\">${_SCRIPT_NAME}</a></p>
  </footer>
  <a href=\"#\" id=\"toTop\">&#x2B06;</a>
</body>"
}


# Fix the user's incorrect settings
fix_setting() {
  # Check THEME_COLOR is hex code color
  if [[ ! "$MAIN_COLOR" =~ ^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$ ]]; then
    echo -e "$RED!$RESET ${YELLOW}THEME_COLOR$RESET should be hex code color [line:12]"
    MAIN_COLOR="#CAD926"
  fi
  
  # Remove last slash in BASE_URL
  if [[ "$BASE_URL" == */ ]]; then
    BASE_URL="${BASE_URL%/}"
  fi

  # Add https in BASE_URL
  if [[ "$BASE_URL" != http* ]]; then
    BASE_URL="http://$BASE_URL"
  fi

  # Fixing file/folder name with whitespace
  find . -depth -name "* *" | while IFS= read -r _file; do
    new_name=$(echo "$_file" | tr ' ' '_')
      
    mv "$_file" "$new_name"
  done
}

# Markdown to HTML converter
md2html() {
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

# html
# details summary, comment, br, iframe
MOD=$(echo "$MOD" | sed -E '
  s/&lt;(\/?details)&gt;/<\1>/
  s/&lt;(\/?summary)&gt;/<\1>/g
  s/&lt;(!-- .* --)&gt;/<\1>/  
  s/&lt;br ?\/?&gt;/<br>/
  s/&lt;(iframe.*)&gt(.*)&lt;\/iframe&gt;/<\1>\2<\/iframe>/
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
  s/^<h([1-6])>(.*) ?\{# ?(.*)\}<\/h\1>$/<h\1 id="\3">\2<a href="#\3"> 🔗<\/a><\/h\1>/
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

# em strong  code
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
  s/([^\\]?)\^(.*[^\\])\^/\1<sup>\2<\/sup>/g
  s/([^\\]?)~(.*[^\\])~/\1<sub>\2<\/sub>/g
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

# dl dt
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

echo "$MOD"
}


# Make folder structure.
make_directory() {
  local folders=("posts" "tags" "write" "assets" "checksum" "backup")

  for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
      mkdir "$folder"
    fi
  done

  # Copy taglist.txt for find diffrence. 
  if [[ -e ./checksum/taglist.txt ]]; then
    cp ./checksum/taglist.txt temp_taglist.txt
  else
    touch ./checksum/taglist.txt
    touch temp_taglist.txt
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
  DESCRIPTION="404 page not found"
  NEW_PATH="./404.html"

  {
    make_before
    echo "<p>404?!</p>"
    make_after
  } > 404.html

  echo -e "  $BLUE+$RESET 404.html"
}

# Make markdown file list
# 
# Each lines has
#   checksum file_size file_path
# For removed files, set checksum as 000 temparaly
make_list() {
  local new='./temp_cksum_md.txt'
  local old='./checksum/cksum_md.txt'

  find ./write/ -type f -name "*.md" -exec cksum {} \; > $new

  if [ ! -e $old ]; then
    touch $old
  else
    local temp_removed=''
    
    while IFS=' ' read -r _c _s _file; do
      if [ -n "$_file" ] && ! grep -qF $_file $new; then
        temp_removed+="000 000 $_file"$'\n'
      fi
    done < $old
    
    if [ -n "$temp_removed" ]; then
      echo "$temp_removed" >> $new
    fi
  fi
}

# Update checksum/taglist.txt
#
# taglist.txt has lines like
#   tag_name html_link_1 html_link_2 ...
# Each lines start with tag name.
# Each links are seperated by whitespace.
# Tags are all lowercase
# 
# $1: TAGS(tags are seperated by whitespce)
update_tags_list() {
  local tags="$1"
  local taglist="./checksum/taglist.txt"
  local tag_line=""
  
  # Make taglist.txt
  if [ ! -f "$file" ]; then
    touch "taglist"
  fi

  # Remove useless whitespace. Change to lowercase 
  tags=$(echo "$tags" | xargs | tr '[:upper:]' '[:lower:]')
  
  for tag in $tags; do 
    tag_line=$(grep "^$tag " "$taglist")

    if [ -z "$tag_line" ]; then
      # Add a new tag. 
      echo "$tag $NEW_PATH" >> "$taglist"
    elif [[ "$tag_line" != *"$NEW_PATH"* ]]; then
      # Add a path in existing tag. 
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # mac os
        sed -i '' "/^$tag / s|$| $NEW_PATH|" "$taglist"
      else
        # linux
        sed -i "/^$tag / s|$| $NEW_PATH|" "$taglist"
      fi
    fi
  done

  # Remove old tag. 
  local pattern='^'
  pattern+=$(echo "$tags" | sed 's/ /\\|^/g')

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # mac os
    # Remove old tag
    sed -i '' "/$pattern /! s| $NEW_PATH||g" "$taglist"
    # Remove empty tag. 
    sed -i '' '/^[^ ]*$/d' "$taglist"
  else
    # linux
    sed -i "/$pattern /! s| $NEW_PATH||g" "$taglist"
    sed -i '/^[^ ]*$/d' "$taglist"
  fi
}

# File status
#
# Status: "U"pdated, "N"ew, "R"emoved,  no "C"hange
# ckum_md.txt has previous file list
# 
# $1: a file path
# $2: checksum of $1
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
# Remove html file and file path in taglist.txt. 
#
# $1: Removed file path .html
remove_file() {
  local file_path="$1"
  local taglist='./checksum/taglist.txt'
  
  rm "$file_path"

  # Remove tags
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # mac os
    sed -i '' -e "s| $file_path||g" $taglist
    sed -i '' '/^[^ ]*$/d' $taglist
  else
    # linux
    sed -i -e "s| $file_path||g" $taglist
    sed -i '/^[^ ]*$/d' $taglist
  fi

  echo -e "  $RED-[Remove]$RESET $file_path"
}

# Get frontmatter from markdown
#
# $1: markdown file path
frontmatter() {
  local file_path="$1"
  
  local frontmatter=$(awk '
    BEGIN { part=0 }
    /^---/{ part++ }
    part==1 { print }
  ' "$file_path")
  CONTENTS=$(awk '
    BEGIN { part=0 }
    /^---/{ part++ }
    part==2 { print }
    part>2 { print }
  ' "$file_path" | sed '1d')

  TITLE=$(echo "$frontmatter" | awk -F': ' '/^title:/{print $2}')
  DESCRIPTION=$(echo "$frontmatter" | awk -F': ' '/^description:/{print $2}')
  DATE=$(echo "$frontmatter" | awk -F': ' '/^date:/{print $2}')
  LASTMOD=$(echo "$frontmatter" | awk -F': ' '/^lastmod:/{print $2}')
  TAGS=$(echo "$frontmatter" | awk -F': ' '/^tags:/{print $2}')
  DRAFT=$(echo "$frontmatter" | awk -F': ' '/^draft:/{print $2}')
  PIN=$(echo "$frontmatter" | awk -F': ' '/^pin:/{print $2}')

  # Fixing frontmatters
  if [ -z "$DATE" ]; then
    # Default date is today
    DATE=$(date +"%Y-%m-%d")
  fi
  
  if [ -z "$TITLE" ]; then
    TITLE="New post $DATE"
  else
    # Fix <,> to &lt; &gt;
    TITLE=${TITLE//</\&lt;}
    TITLE=${TITLE//>/\&gt;}
  fi

  if [ -n "$DESCRIPTION" ]; then
    # Fix <,> to &lt; &gt;
    DESCRIPTION=${DESCRIPTION//</\&lt;}
    DESCRIPTION=${DESCRIPTION//>/\&gt;}
  fi
  
  if [ -n "$TAGS" ];then
    # Only allow alphabets, numbers and dash underscore in tags
    TAGS=$(echo "$TAGS" | sed 's/[^ a-zA-Z0-9_-]//g')
    # Remove duplicated tags
    TAGS=$(echo "$TAGS" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ')
  fi

  if [ -n "$PIN" ] && [[ ! "$PIN" =~ ^[1-9][0-9]*$ ]]; then
    echo -e "$RED!$RESET Frontmatter: ${YELLOW}pin$RESET should be a number [$file_path]"
    PIN=''
  fi
}

# Converting markdown files
#
# $1: file path .html
# $2: updated date
converting() {
  local file_path="$1"

  # Make directory
  mkdir -p "$(dirname "$file_path")"

  # Save html text in html file
  {
    make_before
    md2html "$CONTENTS"
    if [ -n "$CUSTOM_HTML_ARTICLE_FOOTER" ]; then
      make_after 1
    else
      make_after
    fi
  } > $file_path

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
  
  echo -e "  $BLUE+[$status]$RESET $file_path"
}

# Convert link list to html format, grouped by year and month
#
# $1: list of (date url title)
# return: html string
group_list() {
  local origin="$1"
  local result=""
  local temp_date=""

  # Sort by reverse chronicle
  origin=$(echo "$origin" | grep -v '^$' | sort -k1,1r)
  
  # Group the posts by year-month
  while IFS= read -r -a _line; do
    yyyy_mm_dd="${_line[0]}"
    url=$(echo "${_line[1]}" | sed 's/index.html$//')
    title="${_line[@]:2}"
    
    if [ -z "$temp_date" ]; then
      temp_date="${yyyy_mm_dd:0:7}"
    elif [ "$temp_date" != "${yyyy_mm_dd:0:7}" ]; then
      result+=$'\n'
      temp_date="${yyyy_mm_dd:0:7}"
    fi
    
    result+="$yyyy_mm_dd $url $title"$'\n'
  done <<< "$origin"
    
  # Wraping with html tag
  result=$(echo "$result" | sed -E '
    s/^([0-9]{4}-[0-9]{2})(-[0-9]{2}) ([^ ]*) (.*)$/<li><time>\1<\/time><ul>\n<li><time>\1\2<\/time> <a href="\3">\4<\/a><\/li>\n<\/ul><\/li>/
  ')
  result=$(echo "$result" | sed -E '
    /^<\/ul><\/li>$/ {
      N
      /<\/ul><\/li>\n<li>.*<ul>/d
    }
  ')

  # Remove index.html in url
  result=$(echo "$result" | sed -E '
    s/(href=".*\/)index.html">/\1">/
  ')
    
  echo "$result"
}

# Make all-posts.html
#
# List of every posts link
make_all_posts_html() {
  reset_var
  TITLE="All Posts"
  DESCRIPTION="Every post links of $BLOG_NAME"
  NEW_PATH="./all-posts.html"

  {
    make_before
    echo "<ul>"
    group_list "$ALL_POSTS"
    echo "</ul>" 
    make_after
  } > all-posts.html

  echo -e "  $BLUE+$RESET all-posts.html"
}

# Make all-tags.html
#
# Contain every tag page link in tags/
make_all_tags_html() {
  local html_all_tags=""

  # Find all tags and counts
  while IFS= read -r _line; do
    tag=$(echo "$_line" | awk '{print $1}')
    count=$(( $(echo "$_line" | wc -w) - 1 ))
      
    html_all_tags+="$tag $count\n"
  done < ./checksum/taglist.txt

  # Sort tags by abc order
  html_all_tags=$(echo -e "$html_all_tags" | sort)

  # Wrapping with html tags
  html_all_tags=$(echo "$html_all_tags" | sed -E "
    s|^([^ ]*) ([0-9]*)$|<li><a href=\"$BASE_URL/tags/\1.html\">\1</a> (\2)</li>|
  ")

  reset_var
  TITLE="All Tags"
  DESCRIPTION="Every tags in $BLOG_NAME"
  NEW_PATH="./all-tags.html"

  {
    make_before
    echo "<ul>"
    echo "$html_all_tags"
    echo "</ul>" 
    make_after
  } > all-tags.html

  echo -e "  $BLUE+$RESET all-tags.html"
}

# Make every tag pages
make_tag_pages() {
  local tag=''
  local links=''
  local old='./checksum/taglist.txt'
  local new='temp_taglist.txt'

  # Find removed tag
  local removed_tag=$(grep -Fxv -f $old $new)
  local remove_lines=''
  
  if [ -n "$removed_tag" ]; then
    while IFS=' ' read -r _tag _r; do
      rm "./tags/$_tag.html"
      remove_lines="$(grep ">$_tag</a>" all-tags.html)$'\n'"
    done <<< "$removed_tag"
  fi

  # Remove removed tags
  grep -Fvx -f <(echo "$remove_lines") all-tags.html > temp && mv temp all-tags.html

  # Find updated or added tag
  local updated_tag=$(grep -Fvx -f $new $old)
  local md_path=""
  local html_all_posts=""
  reset_var

  if [ -n "$updated_tag" ]; then
    while IFS= read -r _line; do
      tag=$(echo "$_line" | awk '{print $1}')
      links=$(echo "$_line" | cut -d' ' -f2-)
      html_all_posts=""

      for url in $links; do
        md_path=${url/posts/write}
        md_path=${md_path/.html/.md}

        frontmatter "$md_path"

        if [ "$DRAFT" != "true" ] && [ "$DRAFT" != "True" ] && [ "$DRAFT" != "TRUE" ] && [ "$DRAFT" != "1" ]; then
          url="$BASE_URL${url:1}"
          html_all_posts+="$DATE $url $TITLE"$'\n'
        fi
      done

      reset_var
      TITLE="$tag"
      DESCRIPTION="$tag tag in $BLOG_NAME"
      NEW_PATH="./tags/$tag.html"
  
      {
        make_before
        echo "<ul>"
        group_list "$html_all_posts"
        echo "</ul>" 
        make_after
      } > "$NEW_PATH"
    done <<< "$updated_tag"
  
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

  # line = date url title
  while IFS= read -r _line; do
    rss_date=$(date -d "$(echo "$_line" | awk '{print $1}')" +"%a, %d %b %Y 00:00:00 GMT")
    url=$(echo "$_line" | awk '{print $2}')
    file_path=${url/"$BASE_URL"/.}
    words=($_line)
    title="${words[@]:2}"
    article=$(sed -n '/<main>/,/<\/main>/p' "$file_path")

    echo "<item>
  <title>$title</title>
  <link>$url</link>
  <guid>$url</guid>
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
  # Recent posts
  local html_recent_posts=''
  if [ "$RECENT_POSTS_COUNT" -gt 0 ]; then
    local recent_posts=$(echo "$ALL_POSTS" | sort -r -k1,1 | head -n "$RECENT_POSTS_COUNT")

    if [ -n "$recent_posts" ]; then
      html_recent_posts="<hr>
<div id=\"recent-posts\">
  <h3>⏰ Recent posts</h3>
  <ul>"

    while IFS=' ' read -r _date _url _title; do
      file_path=".$(echo "${_url}" | awk -F"$BASE_URL" '{print $2}')"
      description=$(awk -F'"' '/description/{print $4; exit}' ${file_path})
      _url=$(echo "$_url" | sed 's/index.html$//')

      html_recent_posts+="
<li>
  <p><time>${_date}</time> <a href=\"${_url}\">${_title}</a></p>
"
      if [ -n "$description" ]; then
        html_recent_posts+="  <p class=\"recent-description\">$description</p>
"
      fi
      html_recent_posts+="</li>
"
    done <<< "$recent_posts"

    html_recent_posts+="
  </ul>
</div>"
    fi
  fi

  # Pinned posts
  local html_pinned_posts=''
  if [ -n "$PINNED_POSTS" ]; then
    PINNED_POSTS=$(echo "$PINNED_POSTS" | sort -k1,1n)

    html_pinned_posts+="
<hr>
<div id=\"pinned-posts\">
  <h3>📌 Pinned posts</h3>
  <ul>
"

    while IFS='|' read -r _order _date _url _title _description; do
      if [ -z "$_date" ]; then
        continue
      fi

      _url=$(echo "$_url" | sed 's/index.html$//')
      html_pinned_posts+="
<li>
  <p><time>${_date}</time> <a href=\"${_url}\">${_title}</a></p>
"
      if [ -n "$_description" ]; then
        html_pinned_posts+="  <p
class=\"pinned-description\">$_description</p>
"
      fi
      html_recent_posts+="</li>
"
    done <<< "$PINNED_POSTS"
    
    html_pinned_posts+="
  </ul>
</div>
"
  fi

  # Make index.html
  reset_var
  TITLE="$BLOG_NAME"
  DESCRIPTION="$AUTHOR_NAME's $BLOG_NAME"
  NEW_PATH="./index.html"

  {
    make_before
    echo "<div id=\"profile\">"
    md2html "$PROFILE"
    echo "</div>"
    echo "$html_pinned_posts"
    echo "$html_recent_posts"
    make_after 
  } > "$NEW_PATH"

  echo -e "  $BLUE+$RESET index.html"
}

# Copy assets in write/ to posts/
copy_assets() {
  local new='./temp_cksum_asset.txt'
  local old='./checksum/cksum_asset.txt'

  if [ ! -e "$old" ]; then
    touch "$old"
  fi

  find ./write/ -type f ! -name "*.md" -exec cksum {} \; > $new

  # Find removed assets and remove them
  local removed_asset=$(awk 'NR==FNR{a[$3]; next} !($3 in a)' $new $old)

  if [ -n "$removed_asset" ]; then
    while IFS=' ' read -r _c _s _file; do
      _file=${_file/.\/write/.\/posts}
      rm $_file
    done <<< "$removed_asset"
  fi

  # Find updated or added asset
  local new_asset=$(grep -Fvx -f $old $new)
  local new_path=''

  if [ -n "$new_asset" ]; then
    while IFS=' ' read -r _c _s _file; do
      new_path=$(echo "$_file" | sed 's/^\.\/write/\.\/posts/')
      mkdir -p "$(dirname "$new_path")"
      cp "$_file" "$new_path"
    done <<< "$new_asset"
  fi

  mv $new $old

  if [[ -n "$removed_asset" || -n "$new_asset" ]]; then
    echo -e "  $BLUE+$RESET Copy assets in write/ to posts/"
  fi
}

# Make backup .tar.gz
make_backup() {
  local backup_list=$(ls -v ./backup/*.tar.gz 2>/dev/null)
  local backup_count=$(echo "$backup_list" | wc -l)

  # Remove old backups
  if [ "$backup_count" -gt 14 ]; then
    echo "$backup_list" | head -n $(($backup_count - 14)) | while read -r _file; do
      rm "$_file"
    done
  fi

  # Create backups
  tar -czf "./backup/backup_$(date +%Y%m%d_%H%M%S).tar.gz" ./bw.sh ./write ./assets
}

# Check build or rebuild
#
# Rebuild if this script is modified
build_rebuild() {
  local old='./checksum/cksum_script.txt'
  local new=$(cksum "$_SCRIPT_FILE_NAME")
  
  if [ ! -e $old ] || [[ "$new" != $(cat $old) ]]; then
    echo "$new" > $old
    echo -n > ./temp_taglist.txt
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
  ${BLUE}1.$RESET Open $YELLOW$_SCRIPT_FILE_NAME$RESET and edit settings. 
  ${BLUE}2.$RESET Create a markdown file in $YELLOW./write/$RESET
    - Markdown files should starts with frontmatter. 
    $YELLOW---
    title: New post
    description: Description of this post.
    date: 2025-02-05
    lastmod: 2025-05-02
    tags: tag1 tag2
    draft: false
    pin: false
    ---$RESET
    - [date] and [lastmod](last modified date) should be yyyy-mm-dd format. 
    - [tags] are seperated with whitespace. 
    - [description], [lastmod], [tags] [draft] and [pin] are option.
  ${BLUE}3.$RESET Run ${YELLOW}./$_SCRIPT_FILE_NAME b$RESET
  ${BLUE}4.$RESET Now your posts are in ${YELLOW}./posts/$RESET
"
}

# Main code
ARG="$1"
if [[ "$#" -eq 0 || "$ARG" == h* || "$ARG" == H* ]]; then
  show_help
elif [[ "$ARG" == b* || "$ARG" == B* ]]; then
  fix_setting
  make_directory

  # Check this script is modified. 
  ARG=$(build_rebuild)

  echo -e "Run $GREEN$_SCRIPT_NAME$RESET $_SCRIPT_VERSION [$ARG]"
  
  make_list

  echo -e "$BLUE*$RESET Converting..."

  while IFS=' ' read -r _checksum _s _file; do
    if [ -z $_file ]; then
      continue
    fi
    
    reset_var
    FILESTATUS=$(get_file_stat "$_file" "$_checksum")

    NEW_PATH=${_file/write/posts}
    NEW_PATH=${NEW_PATH/.md/.html}
    
    if [ "$FILESTATUS" = "R" ]; then
      remove_file "$NEW_PATH"
      COUNT_CHANGE=1
    else
      frontmatter "$_file"

      # Check draft is false
      if [ "$DRAFT" != "true" ] && [ "$DRAFT" != "True" ] && [ "$DRAFT" != "TRUE" ] && [ "$DRAFT" != "1" ]; then
        # Update file list
        ALL_POSTS+="$DATE $BASE_URL${NEW_PATH:1} $TITLE"$'\n'

        # Update pinned posts list
        if [ -n "$PIN" ]; then
          PINNED_POSTS+="$PIN|$DATE|$BASE_URL${NEW_PATH:1}|$TITLE|$DESCRIPTION|"$'\n'
        fi

        # Update tags list
        if [ -n "$TAGS" ]; then
          update_tags_list "$TAGS"
        fi
        
        # Build new or updated posts
        # Or rebuild every posts
        if [[ ! ("$FILESTATUS" == "C" && "$ARG" == b*)  ]]; then
          converting "$NEW_PATH"
          COUNT_CHANGE=1
        fi
      fi
    fi
  done < ./temp_cksum_md.txt

  if [[ "$COUNT_CHANGE" == 0 ]];then
    echo -e "  $BLUE*$RESET There is no changes!"
  else
    # update cksum_md.txt
    grep -v '^000 ' ./temp_cksum_md.txt > ./checksum/cksum_md.txt
    rm ./temp_cksum_md.txt

    echo -e "$BLUE*$RESET Make resources..."
    make_index_html
    if [[ ! -e 404.html || "$ARG" == r* ]]; then
      make_404_html
    fi
    if [[ ! -e style.css || "$ARG" == r* ]]; then
      make_style_css
    fi
    if [[ ! -e robots.txt || "$ARG" == r* ]]; then
      make_robots_txt
    fi
    make_rss_xml
    if [[ ! -e sitemap.xml || "$ARG" == r* ]]; then
      make_sitemap_xml
    fi
    make_all_posts_html
    make_all_tags_html
    make_tag_pages 
  fi

  copy_assets
  rm temp_taglist.txt
  make_backup

  # Remove empty folders
  find ./posts -type d -empty -delete
  
  echo -e "Done in $YELLOW$(( ($(date +%s%N) - start_time) / 1000000 ))${RESET}ms!"
else
  echo -e "$RED! Invaild argument$RESET
If you need help, $YELLOW./$_SCRIPT_FILE_NAME help$RESET "
fi
