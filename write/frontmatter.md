---
title: Frontmatter
description: About frontmatter
date: 2025-04-17
lastmod: 2025-04-26
tags: sample frontmatter blog tutorial
pin: 3
---

```
---
title: Frontmatter
description: About frontmatter
date: 2025-04-17
lastmod: 2025-04-26
tags: sample frontmatter blog
draft: true
pin: 1
banner: image.png
---
```

||Required|Default vaule|Type|
|---|---|---|---|
|title|O|New post `yyyy-mm-dd`|String|
|description|o|.|String|
|date|O|`yyyy-mm-dd`|yyyy-mm-dd|
|lastmod|X|.|yyyy-mm-dd|
|tags|X|.|String|
|draft|X|`false`|bool|
|pin|X|.|int|
|banner|X|.|String|

`yyyy-mm-dd` is build date.

---

This is a yaml-like syntax. 

There must always be a **space** after the **colon(:)**. 

The `title` and `date` are required, while the rest are optional. But I would like to include a `description` as much as possible.

---

`date` and `lastmod` must always be written in the format *yyyy-mm-dd*. 

`tags` are separated by spaces. Tags must only use alphabets, numbers, dashes(-), and underscores(_). Duplicate tags will be ignored.

If you want to pin a post, you need to enter a **natural number** in the `pin`. The smaller the number, the higher it will appear in the *Pinned posts*. For example, `pin: 1` will be at the top. If you do not want to pin a post, you can either leave it blank or delete the line.

The `banner` image can use relative paths, absolute paths, or external links. 
