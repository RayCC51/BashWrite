---
title: Frontmatter
description: About frontmatter
date: 2025-04-17
lastmod: 2025-04-24
tags: sample frontmatter blog
---

```
---
title: Frontmatter
description: About frontmatter
date: 2025-04-17
lastmod: 2025-04-24
tags: sample frontmatter blog
draft: true
pin: 1
---
```

This is a yaml-like syntax. 

There must always be a **space** after the ***colon(:)***. 

The `title` and `date` are required, while the rest are optional.

<br>

`date` and `lastmod` must always be written in the format *yyyy-mm-dd*. 

`tags` are separated by spaces. Tags must only use alphabets, numbers, dashes(-), and underscores(_). Duplicate tags will be ignored.

If you want to pin a post, you need to enter a **natural number** in the `pin`. The smaller the number, the higher it will appear in the *pinned posts list*. For example, `pin: 1` will be at the top. If you do not want to pin a post, you can either leave it blank or delete the line.


||Default vaule|
|---|---|
|title|New post `yyyy-mm-dd`|
|description|•|
|date|`yyyy-mm-dd`|
|lastmod|•|
|tags|•|
|draft|`false`|
|pin|•|

`yyyy-mm-dd` is build date.
