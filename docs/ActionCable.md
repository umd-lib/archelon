# Action Cable

## Introduction

Archelon uses the Rails [Action Cable] functionality to provide dynamic updates
to the GUI, in particular status updates for Export Jobs, Import Jobs, and
Publish Jobs.


## Local Development Environment

⚠️ **Note:** Action Cable may not work reliably with Firefox in the local
development environment, so dynamic status updates MAY NOT occur (in which
case it is necessary to refresh the browser page periodically to see the
status updates).

Dynamic status updates *DO* appear to work reliably in the local development
environment when using Chrome or Safari.

It is unclear why this is the case, but is possibly related to the use of
`archelon-local`, instead of `localhost` as the hostname in the local
development environment, as a typical error seen in the browser console is:

```text
Firefox can’t establish a connection to the server at ws://archelon-local:3000/cable.
```

It is not possible to use `localhost` as the hostname, due to DIT restrictions
on the CAS server (the CAS server does not allow authentication from
`localhost`).

## Action Cable Server

Action Cable runs "in app", so a separate stand-alone Action Cable server
is not required.

The application listens for WebSocket requests on the default `/cable`
endpoint.

## Channel Adapters

By default, Archelon uses the `aync` adapter in development, and the `redis`
adapter in production. The URL of the Redis server is configured using the
environment variable `ARCHELON_REDIS_URL` and should include the protocol
`redis:`, the hostname, and the port of the Redis server (e.g.,
`redis://fcrepo-archelon-redis:6379`)

## Action Cable Messages

Action Cable messages provide status updates for export, import, and publish
jobs, so in the following "jobs" refers to all three types.

When running jobs, the status of the jobs is updated dynamically using the
Rails [Action Cable] functionality. ActionCable enables the browser to receive
messages from the server containing data about job status. Client-side
Javascript is then used to update the relevant portion of the page, so that
the status information is displayed to the user without having to perform a
page reload.

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

## See Also

* [Archelon ↔ Plastron Asynchonous Job Information Flow](img/MessageFlow.svg)
* [ADR archelon-0005: Dynamic Status Update Reliability](decisions/0005-dynamic-status-update-reliability.md)
* [Official documentation for Action Cable in Rails 7.1](https://guides.rubyonrails.org/v7.1/action_cable_overview.html)

[Action Cable]: https://guides.rubyonrails.org/v7.1/action_cable_overview.html
