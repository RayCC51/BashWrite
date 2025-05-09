---
title: Images in the posts
description: How to include images in the posts
date: 2025-04-20
tags: sample blog image tutorial
draft: false
pin: 5
banner: https://place-hold.it/100x400
---

## Include images in posts

You can use markdown to include the images. 

### 1. Prepare images. 

![screenshot.png](screenshot.png)

### 2. Put your images in...

```
your-blog-directory/
├─ write/
│  ├─ new-post/           <<< New!
│  │  ├─ index.md         <<< New!
│  │  ├─ screenshot.png   <<< New!
├─ bw.sh
```

Create a new folder under the `write/` folder. It’s best to name the folder after the title of the new post you will write.

Try to keep only 1 markdown file per folder if possible. This will make file management easier.

Name the markdown file `index.md`. This way, you can have a clean URL.

Also, include any images you want to put in this folder.

### 3. Write markdown.

![screenshot](screenshot.png)

```md
![screenshot](screenshot.png)
```

## Banner Image

### 1. Prepare image or image link

...


### 2. Frontmatter

```
title: ...
description: ...
date: ...
banner: https://place-hold.it/100x400
```

Put your image path or image url in `banner`. 
