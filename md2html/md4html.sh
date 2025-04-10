#!/bin/bash

# input
MOD=$(cat "$1")

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
  s/^<h([0-9]+)>(.*) \{#(.*)\}<\/h\1>$/<h\1 id="\3">\2<\/h\1>/
')

# hr
MOD=$(echo "$MOD" | sed -E '
  s/^-{3,}$/<hr>/g
  s/^\*{3,}$/<hr>/g
  s/^_{3,}$/<hr>/g
')

# footnote
MOD=$(echo "$MOD" | sed -E '
  s/^\[\^(.*)\]: /<a class="footnote" id="footnote-\1" href="#fn-\1">\1<\/a>: /
  
  s/\[\^([^]]+)\]/<sup><a class="footnote" id="fn-\1" href="#footnote-\1">\1<\/a><\/sup>/g
')

# bold italic code
MOD=$(echo "$MOD" | sed -E '
  s/\*\*\*(.*)\*\*\*/<strong><em>\1<\/em><\/strong>/g
  s/\*\*(.*)\*\*/<strong>\1<\/strong>/g
  s/\*(.*)\*/<em>\1<\/em>/g
  
  s/``(.*)``/\\`\1\\`/g
  s/([^\\]+)`(.*[^\\]+)`/\1<code>\2<\/code>/g
')

# del, mark, sup, sub
MOD=$(echo "$MOD" | sed -E '
  s/~~(.*)~~/<del>\1<\/del>/g
  s/==(.*)==/<mark>\1<\/mark>/g
  s/~(.*)~/<sub>\1<\/sub>/g
  s/\^(.*)\^/<sup>\1<\/sup>/g
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
  s/  $/\n/
  s/^( *)([^< ].*)$/<p>\1\2<\/p>/
  s/^(.*[^>])$/<p>\1<\/p>/
  
  /<p> *<\/p>/d
  s/^<p> {4}+(.*)/<p class="indented-p">\1/
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
    /^<p>.*\n<p>.*$/ {
      s/<\/p>\n<p>/\n/
    }
    /^<p> *$\n<\/p>$/d
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
  s/\\</</g
  s/\\>/>/g
')

# output
echo "$MOD"
