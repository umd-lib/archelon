# Metadata Import

## Introduction

Archelon can import metadata using CSV files, via Plastron and STOMP
messaging.

## Import Process

The metadata import process occurs in two stages:

* validate
* import

The "validate" stage uses Plastron to determine the syntactic validity of the
CSV file. A file that has errors must be resubmitted with corrections before
it can be imported.

The "import" stage uses Plastron to perform the actual import. A syntactically
valid file may still fail, for example, if the related records specified in the
import cannot be found in Fedora.
