---
ID: archelon-0005
Status: Active
Date: September 10, 2025

---
# Dynamic Status Update Reliability

## Context

There have been consistent, ongoing problems with dynamic status update
reliability in Archelon, as described in [LIBFCREPO-1553]:

> The dynamic status updates for the Export, Import, and Publish Jobs appears
> to work consistently in the local development environment, but performs
> unreliably in Kubernetes.
>
> The dynamic status updates can work in Kubernetes, it just seems that
> notifications do not always make to the browser, so that the status is not
> updated (or only partially updated, for example, showing a progress of 100%,
> but then never showing “Done”).
>
> It is likely that this is caused by different components involved in the
> notification process (Plastron, the STOMP listeners, Archelon, and the web
> browser) are not reliably connecting to each other.

The current system for dynamic updates involves the following components:

1. Archelon Rails web application
2. Archelon STOMP Listener, implemented as a Rake task and running as a
   separate process/pod from the Archelon webapp
3. Archelon Delayed Jobs, run by the Delayed Jobs Worker running as a separate
   process/container from the Archelon webapp
4. ActiveMQ messaging broker and these message destinations:
    * Jobs queue
    * Job progress topic
    * Job status queue
5. Plastron STOMP Daemon that subscribeds to the jobs queue and sends messages
   to the job progress topic and job status queue
6. Archelon ActionCable components to handle the transmission of current status
   informaion to the UI via WebSockets:
    * Javascript channel (client)
    * Rails channel (server)

## Decision

In order to increase both the reliability and legibility of the dynamic updates
system, we are removing a number of the current components of the system, and
reconfiguring the remaining ones in more direct communication with each other.

### Remove the Job Progress Topic

Modify the Plastron STOMP daemon to use the Job Status Queue for all progress
and status messages.

### Always include "state" and "progress" in status messages

Always include `state` and `progress` keys in the status messages sent to the
Job Status Queue, so that Archelon does not need to reconstruct that
information for each kind of job.

### Remove the Archelon STOMP Listener

Replace the custom `stomp:listen` Rake task implementation with an Apache Camel
route that transmits messages from the Job Status Queue directly to the
Archelon webapp via HTTP.

### Remove Delayed Jobs for Sending UI Updates

Change the trigger for sending UI update notifications through ActionCable from
a set of Delayed Jobs to having the job model class directly call the
ActionCable channel after writing a change to the database.

### Remove Delayed Job for Submitting STOMP Messages

Replace the `SendStompMessageDelayedJob` with a controller concern that allows
the `*JobsController` classes to directly submit a job request message to the
Job Queue via STOMP. If the STOMP server (i.e., ActiveMQ) is not reachable,
this will fail and set the job status to "Error".

Since starting these batch jobs in Archelon is an interactive operation, it is
less important to have a "store-and-forward" type of architecture for job
processing, since the user should see a failure quickly, and can always
manually retry a failed job.

### Remove Origin Checking for ActionCable Requests

While this was working reliably in the development environment, in the
Kubernetes cluster this was unstable. It was also unclear what (if any)
`Origin` header was being sent, and the value seemed inconsistent.

Since the Archelon application requires a user to be on the VPN to connect to
it, removing the origin checking was deemed a low enough risk to proceed.

### Add Redis as the ActionCable Adapter

Contrary to the ActionCable documentation's [own advice], we have been using
the default `async` adapter for ActionCable not only in development, but also
in production. To address this, we will add a Redis server to the umd-fcrepo
stack, and configure Archelon to use it as the ActionCable adapter.

## Consequences

The intended outcome of these changes is to:

1. Improve the reliability of dynamic status updates; all updates should be
   shown in the UI in a timely manner. Reduce the amount of times a user needs
   to manually refresh a page to see a status update.
2. Increase the legibility of the system and make future maintenance and
   improvements easier to implement

Risks introduced by these changes are:

1. Adding a new service (Redis) that we have minimal hands-on experience with.
   Redis is used by Avalon, but there (as here), it functions mainly as an
   opaque backend. It will likely need tuning and adjusting as we gain more
   experience using it.

[LIBFCREPO-1553]: https://umd-dit.atlassian.net/browse/LIBFCREPO-1553
[own advice]: https://guides.rubyonrails.org/v7.1/action_cable_overview.html#async-adapter
