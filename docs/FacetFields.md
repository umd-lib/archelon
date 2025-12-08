# Facet Fields

## Introduction

Archelon has extended the default Blacklight facet functionality to enable
particular facets to be dynamically filtered.

This capability is added to a particular facet by configuring it to use the
"FilterFacetComponent", for example, in "app/controllers/catalog_controller.rb":

```ruby
    config.add_facet_field 'archival_collection__facet', label: 'Archival Collection', component: FilterFacetComponent
    config.add_facet_field 'creator__facet', label: 'Creator', component: FilterFacetComponent
```

## FilterFacetComponent Functionality

The "FilterFacetComponent" provides the following functionality:

In the sidebar:

* The entire facet list is shown (instead of being limited to the configured
  number of entries).
* A search textbox is displayed at the top of the facet. Any text typed in the
  search textbox is used to dynamically filter the facet list.
* The "View All" link has been moved to the right of the search textbox, instead
  of appearing at the end of the list. Selecting this link displays the
  stock Blacklight modal dialog.

In the stock Blacklight modal dialog:

* The facet list is paginated
* The facet list can be sorted either alphabetically or numerically.

## Implementation Notes

The following is meant to describe the process of updating
<https://umd-dit.atlassian.net/browse/LIBFCREPO-1709>.

Blacklight has a Presenter class to contain facet fields that need to be
displayed, whether on the sidebar, or through the modal popup window.

A part of the update was to separate some of the logic when rendering facets in
the sidebar vs in the modal

The filter facet component needed to have all options available when on the
sidebar, and then continue to be paginated when in the modal

The issue was that for facet values you can specify a limit to show how many
facets can appear on the sidebar but then if you remove it and then try to
render the modal, it will continue to show all values, rather than be
paginated.

So the default facet presenter had to be overwritten, by copying the entire
class from blacklight and placing it in the respective place in Archelon.

The changes made were to check for if the modal was open or not, and then
another change to use the blacklight configuration's default more limit for
showing the correct amount of facet options in the modal.

It could not be monkeypatch sadly, since Ruby could not find the original
reference to the class when trying to reopen the class.
