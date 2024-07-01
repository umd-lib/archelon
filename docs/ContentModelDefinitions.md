# Content Model Definitions

## Introduction

This page describes the format of the content model definitions in the
[config/content_models.yml](../config/content_models.yml) file.

## Content Model

A content model consists of a model name and three sections
(`required`, `recommended`, and `optional`). Each of the three sections
contains an array of zero or more field definitions.

Using the "Item" model as an example:

```yaml
Item:
  required:
    - name: 'object_type'
      uri: 'http://purl.org/dc/terms/type'
      label: 'Object Type'
      type: :ControlledURIRef
    - ...

  recommended:
    - ...

  optional:
    - ...
```

If a section has no field definitions, an empty array can be indicated, as in
the "recommended" and "optional" sections for the "Page" model:

```yaml
Page:
  required:
    - name: 'page'
      uri: 'http://purl.org/spar/fabio/hasSequenceIdentifier'
      label: 'Page Number'
      type: :TypedLiteral

  recommended: []
  optional: []
```

## Field Definitions

Each field definition has the following required attributes:

* `name` - The name of the attribute, used as an identifier
* `uri` - A URI describing the type of the attribute
* `label` - A human-readable name for the attribute, displayed in the GUI
* `type` - The React component used to display the field in the GUI

A field definition may also have the following optional attributes:

* `repeatable` - Set as `repeatable: true` to indicate that a field can have
  multiple values. If not set, the field may only have one value.
* `vocab` - used for fields that have a controlled vocabulary, where the value
  is the identifier for vocabulary on the vocabulary server
* `terms` - used with the "vocab" attribute to limit the vocabulary terms
  that are displayed in the GUI. Terms in the array (specified by the "label"
  attribute) will be displayed. If this attribute is not provided, all terms
  from the vocabulary are displayed.
* `edit_only` - Set as `edit_only: true` to indicate that the field should
  only be displayed in the metadata edit form, not on the item detail page.
