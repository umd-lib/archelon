# Solr Configuration

## Core

Set the base URL of the core in the `SOLR_URL` environment variable.

For example: `http://fcrepo-solr:8983/solr/fcrepo`

### Schema and Fields

This application assumes that the Solr field names follow the naming
patterns used by [Solrizer] when building a Solr document. Since some of
these naming patterns rely on Solr's dynamic field capabilities, there
is not currently an exhaustive list of all possible fields. However,
here is Solrizer, umd-fcrepo-solr, and Plastron documentation that
should help explain the field name conventions:

* [Content Model Indexer]
* [Other Indexer Modules]
* [Facet Fields]
* [fcrepo Core Configuration]
* [Item Content Model]

## Endpoints

* Search endpoint: `select`
* Document endpoint: `select`
* JSON query endpoint: _Disabled_

This application uses the same endpoint for both search and document
retrieval in order to simplify the Solr configuration. The JSON query
endpoint is currently disabled (i.e., set to `nil`).

### Parameters

All default parameters for searches should be implemented in the Solr
configuration as part of the `/select` request handler:

```xml
<requestHandler name="/select" class="solr.SearchHandler">
  <lst name="defaults">
    <str name="echoParams">explicit</str>
    <!-- search all fields by default -->
    <str name="q">*:*</str>
    <!-- default to 10 results per page -->
    <int name="rows">10</int>
    <!-- include child documents as nested fields by default -->
    <str name="fl">*,[child]</str>
    <!-- exclude child documents from being top-level results -->
    <str name="fq">!_nest_path_:*</str>
    <!-- default to facet minimum of 1 -->
    <str name="facet.mincount">1</str>
  </lst>
</requestHandler>
```

Since this configuration does not itself enable faceting, the Blacklight
configuration for this application includes a call to `add_facet_fields_to_solr_request!` to ensure that faceting is enabled.

## Search Fields

This implementation replaces the custom functionality implemented in
Archelon 1.x that allowed searching identifiers by wrapping your query
in double quotes. It relies on Blacklight's built-in "search fields"
concept, where you can define multiple combinations of Solr query
parameters that the user can select from a dropdown menu next to the
main search input field.

Note the use of `edismax` as the query parser type (`defType`). This
allows users to more naturally construct their search queries. For more
information, see Solr's documentation about the [dismax] and [edismax]
query parsers.

### Text/Keywords

* **Key:** `text`
* **Label:** Text/Keywords
* **Parameters:**

  | Key       | Value     |
  |-----------|-----------|
  | `df`      | `text`    |
  | `defType` | `edismax` |
  | `q.alt`   | `*:*`     |

### Identifier

* **Key:** `identifier`
* **Label:** Identifier
* **Parameters:**

  | Key       | Value        |
  |-----------|--------------|
  | `df`      | `identifier` |
  | `defType` | `edismax`    |
  | `q.alt`   | `*:*`        |


[Solrizer]: https://github.com/umd-lib/solrizer
[Content Model Indexer]: https://umd-lib.github.io/solrizer/solrizer/indexers/content_model.html
[Other Indexer Modules]: https://umd-lib.github.io/solrizer/solrizer/indexers.html
[Facet Fields]: https://umd-lib.github.io/solrizer/solrizer/faceters.html
[fcrepo Core Configuration]: https://github.com/umd-lib/umd-fcrepo-solr/tree/main/fcrepo/core/conf
[Item Content Model]: https://github.com/umd-lib/plastron/blob/4.5.1/plastron-models/src/plastron/models/umd.py#L31
[dismax]: https://solr.apache.org/guide/solr/latest/query-guide/dismax-query-parser.html
[edismax]: https://solr.apache.org/guide/solr/latest/query-guide/edismax-query-parser.html
