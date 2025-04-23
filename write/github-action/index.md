---
title: Publish on Gihub Pages with github actions
description: How to publish the blog on Github Pages
date: 2025-04-17
lastmod: 2025-04-21
tags: github action pages ghpages publish
draft: false
---

## Download github action

1. Download `.github/workflows/build.yaml` in [Github](https://github.com/raycc51/bashwrite)
2. Put the `build.yaml` in your `your-blog-path/.github/workflows/`

### Directory

```
your_blog/
├─ .github/           <<< New!
│  ├─ workflows/      <<< New!
│  │  ├─ build.yaml   <<< New!
├─ write/
│  ├─ post1.md
│  ├─ post2.md
├─ bw.sh
```

## Settings in github.com

![setting image](pages-setting.png)

0. Push any files in your blog repository, or just run a github action. Then *gh-pages* branch will be created automatically.
1. Go to the your blog repository settings.
2. Settings -> Code and automation - Pages -> Build and deployment
    - Source: Deploy from a branch
    - Branch: gh-pages
3. Save the settings.
4. Your site is live at *https://YOUR-NAME.github.io/* or *https://YOUR-NAME.github.io/REPO-NAME/*
