# Search Customization

## Introduction

This document provides information about Archelon customizations to the
Blacklight search functionality that involve overriding Blacklight classes.

## Blacklight::Routes::Searchable

* `lib/blacklight/routes/searchable.rb`
* `config/routes.rb`

Archelon is unusual in that the “id” parameters for individual item
pages contains the URL of the “fcrepo” server. This URL contains “.”
(period) characters that are confusing to the stock Blacklight route
handlers, causing errors similar to the following (from accessing an item
detail page):

The “lib/blacklight/routes/searchable.rb” file from
Blacklight 8.3.0, was copied and modified to add the constraints:
`\{ id: /\.\*/ \}`.

Also added constraints: `\{ id: /\.\*/ \}` to the affected routes in
“config/routes.rb”.

## Blacklight::SearchState

* `app/controllers/umd_search_state.rb`
* `app/controllers/catalog_controller.rb`

Added a "UmdSearchState" subclass of the default "Blacklight::SearchState" class
to modify the "Identifier" searches so that a search for a fully-qualified
handle URL would find the URL irrespective of whether the user provided an
"http" or "https" URL for the search.

The default Blacklight SearchState is overridden by the following line in the
"CatalogController":

```ruby
  self.search_state_class = UmdSearchState
```
