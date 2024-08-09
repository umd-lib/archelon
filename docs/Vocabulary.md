# Vocabulary

## Introduction

When editing items, some metadata fields use a "controlled vocabulary" in which
only a defined set of values is allowed. These are typically presented using
the "ControlledURIRef" React component in the GUI as a drop-down listbox.

The "controlled vocabularies" for these fields are typically retrieved from the
UMD Vocabulary server, notionally at <http://vocab.lib.umd.edu>.

## Vocabulary Functionality

The existing Archelon functionality is limited to:

* Retrieving controlled vocabularies from a configured vocabulary server, with
  the vocabulary to retrieve typically specified by a content model definition
* Creating the GUI elements needed for metadata editing.

**Note:**  Archelon once provided vocabulary management functionality, but this
functionality has been removed, having been replaced by the
[Grove](https://github.com/umd-lib/grove) application.

## Vocabulary Configuration

### Environment Variables

The following environment variable (defined either in the actual environment,
or via a ".env" file) is used to configure the Vocabulary functionality:

* `VOCAB_LOCAL_AUTHORITY_BASE_URI` - The base URI for the controlled vocabulary
  terms, defining the server to contact for retrieving controlled
  vocabularies. Typically specified with an `http` scheme -- Archelon will
  transparently follow redirects to an `https` endpoint.

### Additional Configuration

The following configuration is defined in the `config/vocabularies.yml` file:

* `access_vocab_identifier` - The vocabulary identifier for the controlled
  vocabulary to be used for the "Access Level" field in Import jobs (typically
  `access`). The "Access Level" metadata field when editing items is
  controlled by the content model definition.

### react_components Demonstation Page

The "react_components" demonstration page shows a sampling of "ControlledURIRef"
components for various vocabularies. To add a vocabulary to the list of
sample components, edit the `sample_vocabulary_ids` variable in the
`app/views/react_components/react_components.html.erb` file.
