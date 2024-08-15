# Action Cable

## Introduction

Archelon uses the Rails "Action Cable" functionality to provide dynamic updates
to the GUI, in particular status updates for Export Jobs, Import Jobs, and
Publish Jobs.

See <https://guides.rubyonrails.org/v7.1/action_cable_overview.html> for
an overview on Action Cable in Rails 7.1.

----
**Note: Action Cable, Local Development Environment and Firefox**

Action Cable does not work correctly with Firefox in the local development
environment, so dynamic status updates WILL NOT occur (it is necessary to
refresh the browser page periodically to see the status updates).

Dynamic status updates DO work in the local development environment when using
Chrome or Safari.

It is unclear why this is the case, but is possibly related to the use of
"archelon-local", instead of "localhost" as the hostname in the local
development environment, as a typical error seen in the browser console is:

```
Firefox can’t establish a connection to the server at ws://archelon-local:3000/cable.
```

It is not possible to use "localhost" as the hostname, due to DIT restrictions
on the CAS server (the CAS server does not allow authentication from
"localhost").

----

## Action Cable Server

Action Cable runs "in app", so a separate stand-alone Action Cable server
is not required.

The application listens for WebSocket requests on the default "/cable"
endpoint.

## Channel Adapters

By default, Archelon uses the `aync` adapter in all environments, including
production.

While the documentation indicates that the "async" adapter is only for
development/testing (because it does not persist, doesn't scale, and may not be
reliable), it is likely sufficient for our current use case of using it to
process status updates.

Previously the PostgreSQL adapter was used, but proved not be reliable, as it
did not gracefully handle unexpected terminations of the database connection
(see [LIBHYDRA-415](https://umd-dit.atlassian.net/browse/LIBHYDRA-415)).

The Redis adapater has been considered in the past, but not implemented.

## Action Cable Messages

Action Cable messages provide status updates for export, import, and publish
jobs, so in the following "jobs" refers to all three types.

When running jobs, the status of the jobs is updated dynamically using the
Rails "Action Cable" functionality. Action Cable enables the browser to receive
messages from the server containing data about job status.
Browser-side JavaScript is then used to update the relevant portion of the page,
so that the status information is displayed to the user without having to
perform a page reload.

### Developer Information

**Note:** The following is developer-level information about how the
dynamic status updates is implemented. It is not necessary to understand this
information to perform exports or imports through the GUI.

#### Channel Streams

For each job in a state other than "complete", the ActionCable client on the
jobs' index page creates a subscription to that job. A subscription is only
created if the authenticated user is either the creator of the job, or if they
are an admin.

#### Channel Data

Status updates to the channels consist of a JSON object with the following
attributes:

* `job` - a JSON-serialized representation of the ImportJob or ExportJob object
* `statusWidget` - HTML representing the status to display for the job

The browser-side JavaScript uses the id in the "job" field to locate the
appropriate DOM element using the "data-job-id" HTML attribute, and replaces
the HTML of the element with the "statusWidget" content.
