#!/bin/bash


# fixme: can not handle more then 2 level indented list
# fixme: more then 4 backtick not working
# fixme: indented blockquote with more then 2 lines, not working
# fixme: table can not align


# input
FILE="syntax.md"
# FILE="test.md"
MOD=$(cat "$FILE")


# escape < > &
MOD=$(echo "$MOD" | sed -E '
  s/&/\&amp;/g
  s/</\&lt;/g
  s/>/\&gt;/g
')

# codeblock
# escape markdown symbols temparely
MOD=$(echo "$MOD" | sed -E '
  /^```/ {
    :a
    N
    /```$/!ba
    s/```([a-zA-Z0-9_]+)?\n/<pre><code class="\1">\n/
    s/```/<\/code><\/pre>/
    s/ class=""//

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
    
    s/&lt;/\\</g
    s/&gt;/\\>/g
    s/&amp;/&/g
  }
')

# h1 ~ h6
MOD=$(echo "$MOD" | sed -E '
  s/^# (.*[^# ])$/<h1>\1<\/h1>/g
  s/^## (.*[^# ])$/<h2>\1<\/h2>/g
  s/^### (.*[^# ])$/<h3>\1<\/h3>/g
  s/^#### (.*[^# ])$/<h4>\1<\/h4>/g
  s/^##### (.*[^# ])$/<h5>\1<\/h5>/g
  s/^###### (.*[^# ])$/<h6>\1<\/h6>/g
')

# hr
MOD=$(echo "$MOD" | sed -E '
  s/^-{3,}$/<hr>/g
  s/^\*{3,}$/<hr>/g
  s/^_{3,}$/<hr>/g
')


# bold italic del code
MOD=$(echo "$MOD" | sed -E '
  s/\*\*\*(.*)\*\*\*/<strong><em>\1<\/em><\/strong>/g
  s/\*\*(.*)\*\*/<strong>\1<\/strong>/g
  s/\*(.*)\*/<em>\1<\/em>/g
  s/~~(.*)~~/<del>\1<\/del>/g
  
  s/``(.*)``/\\`\1\\`/g
  s/([^\\])`(.*)([^\\])`/<code>\2<\/code>/g
')

# mark, sup, sub
MOD=$(echo "$MOD" | sed -E '
  s/==(.*)==/<mark>\1<\/mark>/g
  s/~(.*)~/<sub>\1<\/sub>/g
  s/\^(.*)\^/<sup>\1<\/sup>/g
')

# img a
MOD=$(echo "$MOD" | sed -E '
  s/!\[(.*)\]\((.*) "(.*)"\)/<img src="\2" alt="\1" title="\3">/g
  s/!\[(.*)\]\((.*)\)/<img src="\2" alt="\1">/g

  s/&lt;(.*)&gt;/<a href="\1">\1<\/a>/g
  s/\[(.*)\]\((.*)\)/<a href="\2">\1<\/a>/g
')

# li
# for seperate ul and ol, use il tag for ol
MOD=$(echo "$MOD" | sed -E '
  s/^( {4}*)- (.*)/<ul>\n\1<li>\2<\/li>\n<\/ul>/
  s/^( {4}*)\* (.*)/<ul>\n\1<li>\2<\/li>\n<\/ul>/
  s/^( {4}*)\+ (.*)/<ul>\n\1<li>\2<\/li>\n<\/ul>/
  
  s/^( {4}*)[0-9]+\. (.*)/<ol>\n\1<il>\2<\/il>\n<\/ol>/
')

# clean duplicated ul ol
MOD=$(echo "$MOD" | sed -E '
  /^<\/ul>$/ {
    N
    /^<\/ul>\n<ul>$/ {
      /<\/ul>\n<ul>/d
    }

    /^<\/ul>\n<ol>$/ {
      /<\/ul>\n<ol>/d
    }
  }
  
  /^<\/ol>$/ {
    N
    /^<\/ol>\n<ol>$/ {
      /<\/ol>\n<ol>/d
    }
    
    /^<\/ol>\n<ul>$/ {
      /<\/ol>\n<ul>/d
    }
  }
  
')

# indented ul ol
MOD=$(echo "$MOD" | sed -E '
  s/^( {4}+)(<li>.*)$/\1<li><ul>\n\1\2\n\1<\/ul><\/li>/
  
  s/^( {4}+)(<il>.*)$/\1<il><ol>\n\1\2\n\1<\/ol><\/il>/
')

# clean duplicated indented ul ol
MOD=$(echo "$MOD" | sed -E '
  /^( {4}+)<\/ul><\/li>$/ {
    N
    /^( {4}+)<\/ul><\/li>\n\1<li><ul>$/ {
      /^( {4}+)<\/ul><\/li>\n\1<li><ul>$/d
    }
  }
  
  /^( {4}+)<\/ol><\/il>$/ {
    N
    /^( {4}+)<\/ol><\/il>\n\1<il><ol>$/ {
      /^( {4}+)<\/ol><\/il>\n\1<il><ol>$/d
    }
  }
')

# restore il to li
MOD=$(echo "$MOD" | sed -E '
  s/il>/li>/
')

# checkbox
MOD=$(echo "$MOD" | sed -E '
  s/^<li>\[ \]/<li><input type="checkbox" disabled>/
  s/^<li>\[x\]/<li><input type="checkbox" checked disabled>/
')

# blockquote
BLOCKQUOTE() {
MOD=$(echo "$MOD" | sed -E '
  s/^&gt; (.*)/<blockquote>\n\1\n<\/blockquote>/
  /^&gt;$/d
')

MOD=$(echo "$MOD" | sed -E '
  /^<\/blockquote>$/ {
    N
    /^<\/blockquote>\n<blockquote>$/ {
      s/<\/blockquote>\n<blockquote>/<br>/
    }
  }
')
}

# indented blockquote
while echo "$MOD" | grep -q '^&gt;'; do
  BLOCKQUOTE
done

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
    /^<\/table>\n<table>$/ {
      /^<\/table>\n<table>$/d
    }
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
  s/\\</</g
  s/\\>/>/g
')


# output
echo "$MOD"
