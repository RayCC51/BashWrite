---
title: Giscus Comments
description: How to add comments in your blog
date: 2025-04-27
tags: sample blog comment tutorial
---

## 1. Visit giscus homepage

<https://giscus.app/>

Read the text on the homepage carefully and follow it.

## 2. Giscus setting

If you don't understand something, follow the settings below.

- Page ↔️ Discussions Mapping 
    - [x] Discussion title contains page pathname
- Discussion Category
    - -> Announcements
    - [x] Only search for discussions in this category
- Features
    - [x] Enable reactions for the main post
    - [ ] Emit discussion metadata
    - [x] Place the comment box above the comments
    - [x] Load the comments lazily
- Theme
    - -> Preferred color scheme

## 3. Copy script html code

```html
<script 
  src="https://giscus.app/client.js"
  data-repo="RayCC51/BashWrite"
  data-repo-id="R_kgDOOQp0-w"
  data-category="Announcements"
  data-category-id="DIC_kwDOOQp0-84CpMGk"
  data-mapping="pathname"
  data-strict="0"
  data-reactions-enabled="1"
  data-emit-metadata="0"
  data-input-position="top"
  data-theme="preferred_color_scheme"
  data-lang="en"
  data-loading="lazy"
  crossorigin="anonymous"
  async>
</script>
```

## 4. Paste above code in `bw.sh` - `CUSTOME_HTML_ARTICLE_FOOTER`

```bash
CUSTOM_HTML_ARTICLE_FOOTER="
<script 
  src=\"https://giscus.app/client.js\"
  data-repo=\"RayCC51/BashWrite\"
  data-repo-id=\"R_kgDOOQp0-w\"
  data-category=\"Announcements\"
  data-category-id=\"DIC_kwDOOQp0-84CpMGk\"
  data-mapping=\"pathname\"
  data-strict=\"0\"
  data-reactions-enabled=\"1\"
  data-emit-metadata=\"0\"
  data-input-position=\"top\"
  data-theme=\"preferred_color_scheme\"
  data-lang=\"en\"
  data-loading=\"lazy\"
  crossorigin=\"anonymous\"
  async>
</script>
"
```

You need to escape the `"`. That is, you should change `"` to `\"`.

## 5. Save and run `./bw.sh b`

Now there are comments on your blog post. 

👇👇👇
