# Bash Static Site Generator

Inspired by [bashblog](https://github.com/cfenollosa/bashblog)

## TODO

- [x] make directory
- [x] make config
- [x] make default html, css
- [x] make md to html converter
- [x] make front matter
- [x] make file list
- [x] make arguments
- [x] make tags page
- [x] make posts page
- [ ] error handling
- [ ] make doc
- [x] make rss, sitemap, robots
- [ ] make github action
- [ ] style.css
- [ ] refactoring, speed up

## Quick start

### Install

1. Download `bssg.sh` from [Release page]().
2. Make your blog directory. 
3. Move `bssg.sh` to your blog directory. 
4. Open `bssg.sh`, edit config data and save the file.
5. Open *terminal*, change directory to your blog path and run `./bssg.sh b`

### Write new posts

1. Write markdown file in *write/*.
2. Markdown file should starts with frontmatter
    ```
    ---
    title: My new post
    description: Write description of this post. 
    date: 2025-02-05
    lastmod: 2025-05-02
    tags: tags seperated by a whitespace
    draft: false
    ---
    ```
3. Save your file and run `./bssg.sh b`

## Commends

`./bssg.sh [Argument]`

[Argument] =

    - help
        Show help dialog.   
    - build
        Build new, updated posts.    
    - rebuild
        Rebuild every posts and some resources. 
        If you edit `bssg.sh`, then run rebuild. 


## About directory structure

### Download from repo

- bssg.sh
- readme.md
- .github/ - Download this file if you use github pages.

### Automatically generated: Do not edit these files

- posts/
- tags/
- 404.html
- all-posts.html - Contain every posts.
- all-tags.html - Contain every tags.
- filelist.txt - Contain list of posts, and modified date.
- index.html
- robots.txt
- rss.xml
- style.css
- sitemap.xml
- tags-list.txt - Contain list of  tags and links.

### Automatically generated: User edit these files

- write/ - Write your markdowns in this folder.
- assets/
