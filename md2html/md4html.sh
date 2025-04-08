#!/bin/bash


# fixme: can not handle combination of ul and ol
# fixme: more then 4 backtick not working


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
# for seperate ul and ol, ul use li and ol use il
MOD=$(echo "$MOD" | sed -E '
  s/^( {4}*)- (.*)/\1<li>\2<\/li>/
  s/^( {4}*)\* (.*)/\1<li>\2<\/li>/
  s/^( {4}*)\+ (.*)/\1<li>\2<\/li>/

  s/^( {4}*)[0-9]+\. (.*)/\1<il>\2<\/il>/
')

# indented ul
MOD=$(echo "$MOD" | sed -E '
  /^( {4}+)<li>/ {
    :a
    N
    /^( {4}+)<li>/!b
    s/^/<li><ul>\n/
    s/$/<\/ul><\/li>/
  }
')

# indented ol
MOD=$(echo "$MOD" | sed -E '
  /^( {4}+)<il>/ {
    :a
    N
    /^( {4}+)<il>/!b
    s/^/<il><ol>\n/
    s/$/<\/ol><\/il>/
  }
')

# ul open tag
MOD=$(echo "$MOD" | sed -E '
  /^<li>/ {
    :a
    N
    /^<li>/!b
    s/^/<ul>\n/
  }
')

# ul close tag
MOD=$(echo "$MOD" | sed -E '
  /<\/li>$/ {
    :a
    N
    /<\/li>$/!b
    s/$/\n<\/ul>/
  }
')

# ol open tag
MOD=$(echo "$MOD" | sed -E '
  /^<il>/ {
    :a
    N
    /^<il>/!b
    s/^/<ol>\n/
  }
')

# ol close tag
MOD=$(echo "$MOD" | sed -E '
  /<\/il>$/ {
    :a
    N
    /<\/il>$/!b
    s/$/\n<\/ol>/
  }
')

# restore il to li
MOD=$(echo "$MOD" | sed -E '
  s/il>/li>/
')

# fixing ul ol
MOD=$(echo "$MOD" | sed -E '
  /<\/ul>/ {N; /<ul>/d;}
  /<\/ol>/ {N; /<ol>/d;}
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

# table
MOD=$(echo "$MOD" | sed -E '
  /^|.*|$/,/^$/ { 
    1s/^/<table>\n/ 
    $a\</table>
  }
')

# todo table


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
