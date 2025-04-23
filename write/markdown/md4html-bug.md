---
title: md2html bug list
description: I don't know how to solve these bugs...
date: 2025-04-17
lastmod: 2025-04-21
tag: md html sample bug fixme
---

[md2html](https://github.com/RayCC51/md2html)

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

## Table

### Alignment

|table|table|table|table|
|---|:-:|:--|--:|
|!|!|!|!|

```md
|table|table|table|table|
|---|:-:|:--|--:|
|!|!|!|!|
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

## Bold, Itallic

# Italicized bold

*itallic, **bold and itallic**, itallic*

```md
*itallic, **bold and itallic**, itallic*
```
