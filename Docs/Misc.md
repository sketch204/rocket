#  Misc

## Heading IDs

Rocket will generate and assign an ID for any heading when parsing markdown pages. The heading is generated from the contents of the page. All non-alphanumeric and non-ASCII characters will be stripped and all spaces replaced with dashes. For duplicate IDs a `-x` will be added. De-duplication only works for up to 10 duplicate IDs.  
