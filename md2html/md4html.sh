#!/bin/bash

# input
FILE="syntax.md"
FILE="test.md"
MOD=$(cat "$FILE")


# replace markdown tag to html tag with regexpression

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
  s/^-{3,}$/<hr\/>/g
  s/^\*{3,}$/<hr\/>/g
  s/^_{3,}$/<hr\/>/g
')


# bold italic del code
MOD=$(echo "$MOD" | sed -E '
  s/\*\*\*(.*)\*\*\*/<strong><em>\1<\/em><\/strong>/g
  s/\*\*(.*)\*\*/<strong>\1<\/strong>/g
  s/\*(.*)\*/<em>\1<\/em>/g
  s/~~(.*)~~/<del>\1<\/del>/g
  s/`(.*)`/<code>\1<\/code>/g
')


# img a
MOD=$(echo "$MOD" | sed -E '
  s/!\[(.*)\]\((.*) "(.*)"\)/<img src="\2" alt="\1" title="\3"\/>/g
  s/!\[(.*)\]\((.*)\)/<img src="\2" alt="\1"\/>/g

  s/&lt;(.*)&gt;/<a href="\1">\1<\/a>/g
  s/\[(.*)\]\((.*)\)/<a href="\2">\1<\/a>/g
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
