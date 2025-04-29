---
title: md2html bug list
description: I don't know how to solve these bugs...
date: 2025-04-17
lastmod: 2025-04-23
tags: md html sample bug fixme
---

[md2html](https://github.com/RayCC51/md2html)

## Inline code

### Need escape for special charactors

`<hr>`

`\<hr\>`

`\\ \. \| \# \! \* \+ \- \_ \( \) \{ \} \[ \] \< \> \``

```md
`<hr>`

`\<hr\>`

`\\ \. \| \# \! \* \+ \- \_ \( \) \{ \} \[ \] \< \> \``
```

### Can not use double backtick(``)

``double `code` backtick``

```md
``double `code` backtick``
```

## List

### Other elements insides list

- list
- list

    p
    
- list

    > blockquote

- list

```md
- list
- list

    p
    
- list

    > blockquote

- list
```

## Footnote

### Footnote link with space

How to call[^of this] things[^foot note]?

[^of this]: Can not use whitespace in html id. 

[^foot note]: So this will not working well.

```md
How to call[^of this] things[^foot note]?

[^of this]: Can not use whitespace in html id. 

[^foot note]: So this will not working well. 
```

### Footnote with several lines

Footnote[^with]. 

[^with]: several lines

    should be

    work. 

```md
Footnote[^with]. 

[^with]: several lines

    should be

    work. 
```


## ???

||table|
|---|---|
|q|@|
|π|©|
|∆|•|
|ä|❓|

```md
||table|
|---|---|
|q|@|
|π|©|
|∆|•|
|ä|❓|
```
