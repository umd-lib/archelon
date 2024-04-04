# Sample Vocabularies

## Introduction

This directory contains files created from the JSON returned by the
https://vocab.lib.umd.edu/ server for various vocabularies.

## File Generation

All commands were run from the project directory.

### access.json

```zsh
$ curl --location 'http://vocab.lib.umd.edu/access#' > test/fixtures/files/sample_vocabularies/access.json
```

### rightsStatement.json

```zsh
$ curl --location 'http://vocab.lib.umd.edu/rightsStatement#' > test/fixtures/files/sample_vocabularies/rightsStatement.json
```

### one_term_vocabulary.json

This file is for testing the "one term" vocabulary special case, which does not
have an "@graph" element. As soon as a second term is added, the "@graph"
element is added to the RDF.

This file was generated on April 4, 2024, when the Collection" ("collection")
vocabulary from <http://vocab-test.lib.umd.edu/collection#>
consisted of only one term:

```zsh
$ curl --location 'http://vocab-test.lib.umd.edu/collection#' > test/fixtures/files/sample_vocabularies/one_term_vocabulary.json
```
