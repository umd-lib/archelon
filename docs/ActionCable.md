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

By default, Archelon will use the `delayed_job` queue adapter in all environments.

## Action Cable Messages

Action Cable messages are used for both export and import jobs, so in the
following "jobs" refers to both types.

When running jobs, the status of the jobs is updated dynamically using the
Rails "Action Cable" functionality. Action Cable enables the browser to receive
messages from the server containing data about job status.
Browser-side JavaScript is then used to update the relevant portion of the page,
so that the status information is displayed to the user without having to
perform a page reload.

### Developer Information

**Note:** The following is developer-level information about how the
export/import job dynamic update is implemented. It is not necessary to
understand this information to perform exports or imports through the GUI.

#### Channel Streams

For each job in a state other than "complete", the ActionCable client on the jobs'
index page creates a subscription to that job. A subscription is only created if
the authenticated user is either the creator of the job, or if they are an admin.

#### Channel Data

Status updates to the channels consist of a JSON object with the following
attributes:

* `job` - a JSON-serialized representation of the ImportJob or ExportJob object
* `statusWidget` - HTML representing the status to display for the job

The browser-side JavaScript uses the id in the "job" field to locate the
appropriate DOM element using the "data-job-id" HTML attribute, and replaces
the HTML of the element with the "statusWidget" content.

[archelon-data-import-docker]: https://github.com/umd-lib/umd-fcrepo/blob/main/docs/archelon-data-import-docker.md
[archelon-data-import-local]: https://github.com/umd-lib/umd-fcrepo/blob/main/docs/archelon-data-import-local.md
[umd-fcrepo]: https://github.com/umd-lib/umd-fcrepo
