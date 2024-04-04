# Sample Vocabularies

## Introduction

This directory contains files created from the JSON returned by the
https://vocab.lib.umd.edu/ server for various vocabularies.

## File Generation

All commands were run from the project directory.

### access.json

```
$ curl --location 'http://vocab.lib.umd.edu/access#' > test/fixtures/files/sample_vocabularies/access.json
```

### rightsStatement.json

```
$ curl --location 'http://vocab.lib.umd.edu/rightsStatement#' > test/fixtures/files/sample_vocabularies/rightsStatement.json
```
