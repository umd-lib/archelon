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

## Action Cable Messages and Page Reloads

To provide dynamic updates of import job status, the Rails "Action Cable"
functionality is used to receive messages from the server, and trigger a page
reload in the browser when an import job is updated. This eliminates the need
for a user to manually refresh the page to see the updated status of a job.

### Developer Information

**Note:** The following is developer-level information about how the import
job dynamic update is implemented. It is not necessary to understand this
information to perform imports through the GUI.

#### Channel Streams

An import job is visible to the user that created the job, as well as "admin"
users. When displaying the import jobs "index" page, non-admin users only see
the import jobs they have created, while "admin" users see all the import jobs
in the system. This affects the dynamic update functionality because it means
that:

1) Non-admin users should only see messages about jobs they created.
1) Admin users need messages for all import jobs.

This functionality is handled by having the Action Cable channel support
"user-specific" streams and an "admin" stream.

When a non-admin user accesses the channel, they are subscribed to a
"user-specific" stream. The stream only receives messages related to import
jobs that are visible to the user. There may be multiple "user-specific"
streams -- one for each non-admin user.

When an admin user accesses the channel, they are subscribed to a global "admin"
stream, which is shared among all admin users. The "admin" stream receives all
messages related to *any* import job.

#### HTML Data Atrributes

To provide a smooth user experience, the browser needs to have a
JavaScript-friendly mechanism to determine which which import jobs are being
displayed on the page. This is handled through the following HTML "data"
attributes:

* data-channel
* data-job-id
* data-stage
* data-status

These attributes will appear together to describe an import job. For example,
the import jobs index page may include the following HTML, indicating that
Import Job 76 was successfully imported:

```
<td data-channel="import_jobs" data-job-id="76" data-stage="import" data-status="import_success">
  ...
</td>
```

When dealing with import jobs, the "data-channel" will _always_ be
"import_jobs".

The "data-stage" and "data-status" attributes use the "stage" and "status"
values from the ImportJob model.

One additional attribute that may be present is "data-only-update-on-match".
This attribute indicates that page is only interested in updates to the given
import job. This is typically used on "show" and "edit" pages where information
about a single export job is being displayed. For example:

```
<div style="display: none;" data-channel="import_jobs" data-only-update-on-match="true"
                            data-job-id="76" data-stage="import" data-status="import_success"
```

A page containing a "data-only-update-on-match" attribute for any import job
will only be reloaded in response to an update to the import job(s) displayed
on that page.
