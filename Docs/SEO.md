# SEO

# Usage
Use the `{% seo %}` tag to generate SEO related HTML content. Ideally you would want to place this somewhere in the header of your main page template.

In order for this tag to work, you must provide `seo` data. This can be done either by providing a data file called `seo`, or by adding an `seo` object to the main `rocket` config file. SEO tags will not be generated if no SEO object is found.

You can provide the following data in the SEO object:

- `title`: The title of the website. This will be used for the `<title>` HTML tag.
- `description`: A short description of the website.
- `author`: The author of the website. This can either be provided as a single string, or as an object. When given object, the following keys will be read:
    - `firstName`: Given name of the author.
    - `lastName`: Family name of the author.
    - `username`: A unique username for the author.
- `siteURL`: The root URL of your site, from which all page paths follow. This will be used to derive the canonical URL for pages.
- `locale`: The locale that is used by your site. Should be in the format of `language_REGION`. Default is `en_US`.

From the above list `title`, `description` and `author` may also be specified in the page front matter as an override to the global SEO values. In addition, the pages can provide the following values:
- `excerpt`: For article or blog post type pages, this can contain an excerpt of your content.
- `tags`: For article or blog post type pages, this can be an array of string tags or keywords associated with your article.
- `date`: For article or blog post type pages, this can be the date on which the article is first published.
- `pageType`: This can be one of:
    - `website`: For any generic web pages on the site.
    - `profile`: For pages that act as profile pages for people (or authors).
    - `article`: For article or blog type pages. All pages in the `postsPath` config value will have this type applied to them automatically. 

## Notes
If you have configured SEO and use the SEO tag in your default template, then it will automatically generate a `<title>` HTML tag for you, based on the contextual value of the `title` variable.
