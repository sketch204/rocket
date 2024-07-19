# 🚀 Rocket

This is a utility I built for putting together a static site. 
- It has a basic templating syntax powered by [Stencil](https://github.com/stencilproject/Stencil)
- It supports document front-matter in TOML format, powered by [TOMLKit](https://github.com/LebJe/TOMLKit)
- It supports parsing Markdown files and converting them to HTML, powered by [swift-markdown](https://github.com/apple/swift-markdown)

## Usage

Run the command at the root of your website's directory. By default, it will traverse the whole file tree from the current working directory, processing files as it encounters them. It will then create a new `dist` folder at the current working directory and put together any asset and HTML files in there, in the same structure as they appear in the original project directory.

### Front-matter
All HTML and Markdown pages can provide front-matter in the form of a block surrounded by `+++` lines. For example:

```
+++
title = "Some awesome page title"
description = "The description to this awesome page"
date = 2024-05-18
+++
```

This data will be parsed and provided as context for you to use in your page using Stencil's variable syntax. In short, to reference any values, surround them in double curly braces (`{{ title }}`). Currently only data in TOML format is supported.

### Layouts

You can make direct use of Stencil's templating logic, however for page the syntax can get verbose. Instead you can provide a `layout` value in the page's front matter and the layout will be automatically loaded. By default it will embed the contents in a block called `contents`. The block name can be customized using a `layoutBlockName` value.

### Templating

For information on how the actual templating works refer to [Stencil's Documentation](https://github.com/stencilproject/Stencil?tab=readme-ov-file#the-user-guide). A few customization are provided to make site building easier:
- Every page has access to a `page` object which contains all the information outlined in the page's front-matter. Along with that you have access to the following properties:
    - `inputPath`: The absolute path of the file as it appears in the original project, before processing
    - `outputPath`: The relative path of the file as it will appear in the built website. The path is relative to the `outputPath` property of the config file.
    - `filename`: The full file name of the input file.
    - `filenameWithoutExtension`: Same as `filename` but without the file extension. This can be useful if you want to put together links to different versions of this file.
    - If the page is a *post*, it will also have a `next` and `previous` value which are objects representing the next and previous posts in the `posts` array. For the first and last posts in the series, the `previous` and `next` properties will not be present. 
- The global context has a `posts` array which holds information about all the posts on this site. If your posts have a `date` value in the front matter, then this array will be sorted in reverse chronological order. The array consists of the `page` objects for each post.

#### Data files

Before build the site, the tool will traverse the file tree from the project root and look for any JSON or TOML file. Each found file will be parsed and added to the global context under that file's name.

This can be useful for gathering common data into a single place to reuse across the site. For example you could create a `socials.toml` file and place all social links there.

```toml
github = "link_to_github"
twitter = "link_to_twitter"
contact_email = "some_contact_email"
```

You can then use this data on a page in your site with `{{ socials.contact_email}}`.

#### Filters

In addition to this data, the tool provides a few extra filters not offered by Stencil.
- `site_url`: This filter will prepend a path string with the `baseURL` value from the config file. 
- `date`: Use this filter to format a date object. This uses Apple Foundation's [`DateFormatter`](https://developer.apple.com/documentation/foundation/dateformatter) to format the dates. By default, the `yyyy-MM-dd HH:mm:ss` format will be used. Use the first argument to customize this format.
- `append`: Adds the arguments to the end of the string.
- `prepend`: Adds the arguments to the start of the string.

`site_url` filter

### Customization

Customization can be done by adding a `rocket` file to the root of your project. This file can be either TOML or JSON. Below is a list of values you can customize, all of them have defaults. All paths are from the root directory of the project.

- `postsPath`: The path to the directory that contains all the posts for this site. Before build the website, this directory will be parsed for data to be put in the globally available `posts` array. Default is `posts/`.
- `templatesPath`: The path to the directory that contains all the templates used by this site. Default is `templates/`.
- `includesPath`: The path to the directory that contains all the includes used by this site. Default is `includes/`.
- `outputPath`: The path where the output site should be placed. Default is `dist/`.
- `assetsPaths`: An array of paths that reference assets. Assets are not processed and are simply copied as is. Default is `[ "assets/" ]`. 
- `ignoredPaths`: An array of paths that should not be considered at all. These are skipped when looking at the project. Default is `[]`.
- `baseURL`: The base URL to prepend to any paths that are resolved with the `site_url` filter. Default is none. 
- `defaults`: An array of objects containing defaults to add to front-matter of pages matching a path scope. The order in which these are defined matters, as the first matching path will be applied. Generally you want to list them from most specific to least specific. Each object must have two properties: 
    `path`: A path within the project. Any file that matches this path will have the defaults applied to it.
    `values`: A list of key-value pairs that are the default values to apply to a page's front-matter. These values are applied before a page is parsed. If a page defines custom values with the same names, those take precedence. 
Any value that is defined in the config file that does not match any of the above keys will be placed in a `userProperties` object.

### Syntax Highlighting

By default the markdown parser will parse all code blocks into a HTML blocks that are compatible with [Highlight.js](https://highlightjs.org/#as-html-tags)'s inline highlighting

### Table of Contents

Rocket provides a means for you to generate a table of contents. For any markdown file, the `page` object will have an array called `tableOfContents`. Each object in that array will consist of
- `contents`: The raw contents of the heading as it appears on the page.
- `level`: The level of the heading. You can use this to indent the entries of your table of contents.
- `id`: An ID that will be attached to the heading. You can use this as the `href` of an anchor tag.

Alternatively you can also use the `{% table_of_contents %}` tag. This tag will generate an automatically nested `<ul>` list containing links to each heading in the article.

You can control whether table of contents are generated for individual pages using the boolean `generateTOC` property in the page front-matter.

### More

- [SEO](Docs/SEO.md)
- [Misc](Docs/Misc.md)

## Building

The project can be opened and edited in Xcode. However to generate a release build, it's better to use the Swift CLI.

```sh
swift build -c release
```

By default the binary should then be located at `<project_dir>/.build/<arch>/release/Rocket`. You can then move this binary to a location that is included in your `$PATH` to be able to run this anywhere.
