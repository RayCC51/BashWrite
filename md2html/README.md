# md4html.sh

markdown to html converter written in pure bash(sed)

it support extended markdown [mattcone/markdown-guide](https://github.com/mattcone/markdown-guide)


## quick start

```bash
./md4html.sh your_file.md > result_file.html
```


## diffrences from [mattcone/markdown-guide](https://github.com/mattcone/markdown-guide)

- do not need to escape 
    - angle brackets(<, >), underscore(_)
    - dot after number inside unordered list
- does not support 
    - underscore(_) for bold, itallic. ex) "_em_" does not working
    - other elements inside list
    - definition list (dl dt dd)
    - emoji shortcode like (:smile:). just use 😀 directly
- text above the "===" or "---" line does not converted to heading
- can not use html tag in markdown
- diffrent (-*+) in the same ul is supported
- does not detect url link automatically


## bugs

- list: can not handle more then 2 level indented list
- backtick: more then 4 backtick not working
- table: table can not align
- footnote: footnote name with space does not working
- footnote: note with several lines not working
- p: currently p tag detect the line starts with < and ends with >. that means can not wrap some lines like "<em>a</em>"

- blockquote: should contain other elements. go top
- link: with title
