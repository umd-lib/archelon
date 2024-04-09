# Vocabulary

## Introduction

When editing items, many of the metadata fields specify use of a
"controlled vocabulary" in which only a defined set of values is allowed. These
are typically presented using the "ControlledURIRef" React component in the
the GUI as a drop-down listbox.

These "controlled vocabularies" are typically retrieved from the UMD Vocabulary
server, notionally at <http://vocab.lib.umd.edu>.

## Vocabulary Functionality

The existing Archelon functionality is limited to:

* Retrieving controlled vocabularies from a configured vocabulary server, with
  the vocabulary to retrieve typically specified by acontent model definition
* Creating the GUI elements needed for metadata editing.

Archelon once provided vocabulary management functionality, but this
functionality has been removed, having been replaced by the
["Grove"](https://github.com/umd-lib/grove) application.

## Vocabulary Configuration

### Environment Variables

The following environment variable (defined either in the actual environment,
or via a ".env" file) is used to configure the Vocabulary functionality:

* `VOCAB_LOCAL_AUTHORITY_BASE_URI` - The base URI for the controlled vocabulary
  terms, defining the server that will be contacted for retrieving controlled
  vocabularies. While typically specified with an `http` scheme, Archelon will
  transparently follow redirects to an `https` endpoint.

### Additional Configuration

The following configuration is defined in the `config/vocabularies.yml` file:

* `access_vocab_identifier` - The vocabulary identifier for the controlled
  vocabulary to be used for the "Access Level" field in Import jobs (typically
  `access`). Note that the "Access Level" metadata field when editing items is
  controlled by the content model definition.
