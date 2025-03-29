# Bash Static Site Generator

Inspired by [bashblog](https://github.com/cfenollosa/bashblog)

## TODO

- [x] make directory
- [ ] make config
- [x] make default html, css
- [ ] make md to html converter
- [ ] make front matter
- [ ] make file list
- [x] make arguments
- [ ] error handling
- [ ] make doc
- [ ] make rss, sitemap, robots


## Arguments

`./bssg.sh` = help

`./bssg.sh help` = help

`./bssg.sh build` = build new posts

`./bssg.sh rebuild` = rebuild everything


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
- file_list.txt - Contain list of posts, and modified time. 

- posts/
- tags/

### Generated: User

- write/
- assets/
- - images/
- - fonts/
- - css/
- - js/
- - etc/

## Workflow

### Install

1. Clone this repo
2. Open *bssg.sh* file and edit config

### New post

1. Create new markdown file in *write/*
2. `./bssg.sh build`

### New post drafted

1. Create new markdown file in *write/*
2. New markdown file name should starts with `draft-`

If you want to post drafted file, just remove the name `dratt-` in drafted file.

### Edit post

1. Edit markdown file in *write/*
2. `./bssg.sh build`

### Delete post

1. Remove markdown file in *write/*
