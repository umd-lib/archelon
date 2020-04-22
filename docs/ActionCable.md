# Action Cable

## Introduction

Archelon uses the Rails "Action Cable" functionality to provide dynamic updates
to the GUI.

## Action Cable Server

Action Cable runs "in app", so a separate stand-alone Action Cable server
is not required.

The application listens for WebSocket requests on the default "/cable"
endpoint.

## Channel Adapters

By default, Archelon will use the "async" adapter in the "development" and
"test" environments, and the "postgresql" adapter in the "producton"
environment.

**Note:** No special setup of the Postgres database is needed in production,
because the "postgresql" uses the Postgres-specific "NOTIFY" functionality
to act as the message broker (see [https://stackoverflow.com/a/39980595](https://stackoverflow.com/a/39980595)).
