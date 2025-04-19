---
title: md4html bug list
description: I don't know how to solve these bugs...
date: 2025-04-17
tag: md html sample bug fixme
---

## List

### More than 2 level indented list

- 0 normal
    - 1 indented with 4 space
        - 2 this is not working
            - 3 this too
    - 1
- 0 ...

```md
- 0 normal
    - 1 indented with 4 space
        - 2 this is not working
            - 3 this too
    - 1
- 0 ...
```

### Mixed ul ol list

1. this
    - is
2. okay

- this is
    1. not okay

```md
1. this
    - is
2. okay

- this is
    1. not okay
```

## Table

### More then 2 theads

|table|table|table|
|table|table|table|
|:-:|:--|--:|
|!|!|!|

```md
|table|table|table|
|table|table|table|
|:-:|:--|--:|
|!|!|!|
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
