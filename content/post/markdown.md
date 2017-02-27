+++
date = "2017-02-27T21:53:31+01:00"
title = "Markdown all the way"

+++

I love Markdown. It made me change my mind about writing documentations. Makes it almost pleasant. 

Now, whenever I'm about to write some content I first look for a tool that lets me do it in markdown.
So here's a list of all my makrdown tools.

# [Marp](https://yhatt.github.io/marp/)

![](https://yhatt.github.io/marp/images/marp-screenshot.png)
Let's me create slides in markdown. Clean and simple. Exports to PDF. 
Works really well for prezentations that include code samples. Higlighting works out of the box.
If you want to enforce specific language use:

    ```typescript
    const message:string = `Typescript highligting`;
    ```

# [Hugo](https://gohugo.io/)

Static site generator. I've just started using it to run this blog.
Written in [go](https://golang.org/), so installation is simple and painless (go produces static binaries).
Previously I've fiddled with [jekyll](https://jekyllrb.com/) and [octopress](http://octopress.org/).   
They're both written in ruby. If you're not a ruby developer, then installing ruby software is a pain. 
My own sources where mixed with project files. Just look at my octopress [blog sources](https://github.com/rzymek/rzymek.github.io/tree/source) (with just one post).
A total mess. The posts are hidden in some obscure undercored folder [`source/_posts`](https://github.com/rzymek/rzymek.github.io/tree/source/source/_posts).

Hugo is a breath of fresh air after them. Blog sources [contain](https://github.com/rzymek/rzymek.github.io) only markdown posts, configuration and theme.

# [ReText](https://github.com/retext-project/retext)

![](https://camo.githubusercontent.com/5513bfe0e70a35ff7e34fcf6dc9a38827792761a/68747470733a2f2f612e6673646e2e636f6d2f636f6e2f6170702f70726f6a2f7265746578742f73637265656e73686f74732f7265746578742d6b6465352e706e67)
Stangalone markdown editor with live preview. Just like the standard `gedit` editor, but with markdown preview.

