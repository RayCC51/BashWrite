# Bash Static Site Generator

Inspired by [bashblog](https://github.com/cfenollosa/bashblog)

## TODO

- [x] make directory
- [ ] make config
- [x] make default html, css
- [x] make md to html converter
- [ ] make front matter
- [x] make file list
- [x] make arguments
- [ ] make posts, tags page
- [ ] error handling
- [ ] make doc
- [ ] make rss, sitemap, robots

## Arguments

`./bssg.sh` = help

`./bssg.sh help` = help

`./bssg.sh build` = build new posts

## Directory

### Clone from repo

- bssg.sh
- readme.md
- .github/

### Generated: Do not edit

- index.html
- posts.html - Contain every posts.
- tags.html - Contain every tags.
- style.css
- sitemap.xml
- robots.txt
- feed.rss
- filelist.txt - Contain list of posts, and modified date.

- posts/
- tags/

### Generated: User

- write/
- assets/
  - images/
  - fonts/
  - css/
  - js/
  - etc/

## Workflow

### Install

1. Clone this repo
2. Open *bssg.sh* file and edit config

### New post

1. Create new markdown file in *write/*
2. `./bssg.sh build`

### Edit post

1. Edit markdown file in *write/*
2. `./bssg.sh build`

### Delete post

1. Remove markdown file in *write/*
