# BashWrite - [demo](https://raycc51.github.io/BashWrite/)

Pure bash script for make a blog. 

No dependencies. 

It support extended markdown from [mattcone/markdown-guide](https://github.com/mattcone/markdown-guide)

Inspired by [bashblog](https://github.com/cfenollosa/bashblog)

## Quick start

### Install

1. Download `bw.sh` from [Release page](https://github.com/RayCC51/BashWrite/releases).
2. Make your blog directory. 
3. Move `bw.sh` to your blog directory. 
4. Open `bw.sh`, edit config data and save the file.
5. Open *terminal*, change directory to your blog path and run `./bw.sh b`

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
3. Save your file and run `./bw.sh b`

## Commands

`./bw.sh h`

    Show help dialog. 
    
`./bw.sh b`

    Build blog. 

## About directory structure

### Download from repo

- bw.sh
- readme.md
- .github/ - Download this file if you want to use github pages.

### Automatically generated: Do not edit these files

- checksum/ - Checksum list of markdowns, tags, assets and script.
- posts/
- tags/
- 404.html
- all-posts.html - Contain every posts.
- all-tags.html - Contain every tags.
- index.html
- robots.txt
- rss.xml
- style.css
- sitemap.xml

### Automatically generated: User edit these files

- write/ - Write your markdowns in this folder.
- assets/ - Add any assets in this folder. 
