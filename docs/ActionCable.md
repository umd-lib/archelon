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

A job is visible to the user that created the job, as well as "admin"
users. When displaying the jobs "index" page, non-admin users only see
the jobs they have created, while "admin" users see all the jobs
in the system. This affects the dynamic update functionality because it means
that:

1) Non-admin users should only see messages about jobs they created.
1) Admin users need messages for all jobs.

This functionality is handled by having the Action Cable channel support
"user-specific" streams and an "admin" stream.

When a non-admin user accesses the channel, they are subscribed to a
"user-specific" stream. The stream only receives messages related to
jobs that are visible to the user. There may be multiple "user-specific"
streams -- one for each non-admin user.

When an admin user accesses the channel, they are subscribed to a global "admin"
stream, which is shared among all admin users. The "admin" stream receives all
messages related to *any* job.

Note: There are separate setsof channel streams for "export" and "import" jobs.

#### Channel Data

### Import Jobs

For import jobs, status updates to the chaneel consist of a JSON object with
the following attributes:

* job - a JSON-serialized representation of the ImportJob model
* statusWidget - HTML representing the status to display for the job.

The browser-side JavaScript uses the id in the "job" field to locate the
appropriate DOM element using the "data-job-id" HTML attribute, and replaces
the HTML of the element with the "statusWidget" content.

### Export Jobs

For export jobs, status updates to the channel consist of a JSON object with
the following attributes:

* job - a JSON-serialized representation of the ExportJob model
* htmlUpdate - HTML representing entire table row for the job in the jobs table

The browser-side JavaScript uses the id in the "job" field to locate the
appropriate DOM element export jobs table, and replaces the entire row with
the HTML of the element with the "htmlUpdate" content.

[archelon-data-import-docker]: https://github.com/umd-lib/umd-fcrepo/blob/main/docs/archelon-data-import-docker.md
[archelon-data-import-local]: https://github.com/umd-lib/umd-fcrepo/blob/main/docs/archelon-data-import-local.md
[umd-fcrepo]: https://github.com/umd-lib/umd-fcrepo
