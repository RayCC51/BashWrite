# Bash Static Site Generator

Inspired by [bashblog](https://github.com/cfenollosa/bashblog)

## TODO

- [ ] make directory
- [ ] make config
- [ ] make default html, css
- [ ] make md to html converter
- [ ] make command
- [ ] make doc


## Commands

`./bssg.sh` = help

`./bssg.sh build` = build new posts

`./bssg.sh rebuild` = build everything


## Directory

### Clone from repo

- bb.sh
- readme.md
- .github/

### Generated: Do not edit

- index.html
- posts.html
- tags.html
- style.css
- feed.rss

- posts/
- tags/

### Generated: User

- posts-published/
- posts-draft/
- posts-new/
- assets/
- - images/
- - fonts/
- - css/
- - js/
- - etc/

## Workflow

### Install

1. Clone this repo
2. Open *bb.sh* file and edit config
3. `./bb.sh` -> Generate directories, and show howto

### New post

1. Create new markdown file in *posts-new/*
2. `./bb.sh build`

### New post drafted

1. Create new markdown file in *posts-draft/*

If you want to post drafted file, then just move markdown file in *posts-draft/* to *posts-new/*

### Edit post

1. Move markdown file in *posts-published* to *posts-new/* or *posts-draft/*
2. Edit markdown file
3. `./bb.sh build`

### Delete post

1. Remove markdown file in *posts-published/*
