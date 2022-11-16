# archelon

Archelon is the Web front-end for a [Fedora 4][fedora] repository-based set of
applications known collectively as "umd-fcrepo". The umd-fcrepo system consists
of the following parts:

* [umd-fcrepo-docker][umd-fcrepo-docker] - a set of Docker images for running
  the Fedora repository platform
* [Plastron][plastron] - a utility application for performing batch operations
   on the Fedora repository
* Archelon - a web GUI providing an administrative interface for
  Fedora

While Archelon is technically able to run without access to any other
application, its functionality is extremely limited without Plastron or
the applications provided by umd-fcrepo-docker.

## Archelon Components

Archelon consists of the following components when run in a production
environment:

* A Rails application providing an administrative interface to the Fedora
repository. It uses the [Blacklight][blacklight] gem for providing Solr
search functionality.
* A STOMP listener application for communicating with Plastron using the
[STOMP messaging protocol][stomp] via ActiveMQ
* An SFTP server, used to upload files for inclusion in import jobs

## Interactions with other umd-fcrepo components

Archelon interacts directly with the following umd-fcrepo components:

* [ActiveMQ] - Archelon communicates to Plastron using STOMP messaging mediated by
ActiveMQ queues.
* [Solr] - Archelon communicates directly with the Solr instance in the
"umd-fcrepo-docker" stack for metadata search and retrieval.
* [Plastron] - Archelon uses the HTTP REST interface provided by Plastron to
retrieve information about export and import jobs (some export/import status
information is also provided via STOMP messaging).

## Quick Start

See [Installing Prerequisites](docs/Prerequisites.md) for information on
prerequisites on a local workstation.

### Setup

There are several ways to setup the umd-fcrepo system -- see
[umd-lib/umd-fcrepo/README.md][umd-fcrepo]
for information about setting up a local development environment for Archelon.

### Archelon Setup

The following are the basic steps to run the Archelon Rails application.
Archelon requires other components of the umd-fcrepo system to enable most
functionality.

1. Checkout the code and install the dependencies:
    ```bash
    git clone git@github.com:umd-lib/archelon.git
    cd archelon
    yarn
    bundle install
    ```
2. Create a `.env` file from the `env_example` file and fill in appropriate
   values for the environment variables.
3. Set up the database:
    ```bash
    rails db:migrate
    ```
4. *(Optional)* Load sample "Download URL" data:
    ```bash
    rails db:reset_with_sample_data
    ```
5. In three separate terminals:
   1. Start the STOMP listener:
       ```bash
      rails stomp:listen
      ```
   2. Start the Delayed Jobs worker:
       ```bash
      rails jobs:work
       ```
   3. Run the web application:
       ```bash
       rails server
       ```

Archelon will be available at <http://localhost:3000/>

## Logging

By default, the development environment for Archelon will log at the DEBUG level,
while all other environments will log at the INFO level. To change this, set the
`RAILS_LOG_LEVEL` environment variable in your `.env` file.

In the development environment, the log will be sent to standard output and
the `log/development.log` file, as is standard in Rails application.

In production, set the `RAILS_LOG_TO_STDOUT` environment variable to `true` to
send the log to standard out.

## Access Restriction

In general, Archelon requires a CAS login to access the application,
and the user must have been added to the system by an administrator.

Two notable exceptions are the "ping" endpoint and "public keys" endpoint
(there are also some other minor endpoints, such as import/export status
updates).

The "ping" endpoint is unrestricted, and is suitable for monitoring the
health of the application.

The "public keys" endpoint returns a JSON list of the public keys allowed to SFTP
to the Archelon server. While these are _public_ keys, and hence not
technically a security issue, current SSDR policy is to limit access to this
endpoint to "localhost", or nodes in the Kubernetes cluster.

## Docker

Archelon uses the [boathook] gem to provide [Rake tasks](lib/tasks/docker.rake)
for building and pushing Docker images, as described in the following Dockerfiles:

|Dockerfile                        |Image Name                        |Application|
|----------------------------------|----------------------------------|-----------|
|[Dockerfile](Dockerfile)          |`docker.lib.umd.edu/archelon`     |main Rails application|
|[Dockerfile.sftp](Dockerfile.sftp)|`docker.lib.umd.edu/archelon-sftp`|SFTP server for import/export|

Usage:

```bash
# list the images that would be built, and the metadata for them
rails docker:tags

# builds the images
rails docker:build

# pushes to docker.lib.umd.edu hub
rails docker:push
```

See [umd-lib/umd-fcrepo/README.md][umd-fcrepo] for information about setting up
a local development environment for Archelon using Docker.

When running locally in Docker, the Archelon database can be accessed using:

```bash
# Archelon database backing the Archelon Rails app
psql -U archelon -h localhost -p 5434 archelon
```

### Multi-Platform Docker Builds

It is possible to build a multi-platform Docker image using the `docker buildx`
command and targeting both the `linux/amd64` and `linux/arm64` platforms. As
long as there is a `local` builder configured for buildx, the following will
build and push a multi-platform image:

```bash
docker buildx build \
    --builder local \
    --platform linux/amd64,linux/arm64 \
    --tag docker.lib.umd.edu/archelon:latest \
    --push .
```

## Rake Tasks

See [Rake Tasks](docs/RakeTasks.md)

## File Retrieval configuration

Archelon has the ability to create one-time use URLs, which allow a Fedora
binary file to be downloaded. The random token used for the URLs, and other
information, is stored in the DownloadUrl model.

In production, the URL that patrons use to retrieve the files does not reference
the Archelon server directly, relying instead on a virtual host, which proxies
back to Archelon.

The base URL of the virtual host (i.e., the entire URL except for the random
token, but including a trailing slash) should be set in the `RETRIEVE_BASE_URL`
environment variable. This base URL should be proxied to the
`<ARCHELON_SERVER_URL>/retrieve/` path.

## File downloads and concurrent operation

Archelon has the ability to create one-time use URLs for downloading files from
Fedora. Since downloading files may take considerable time, it is necessary that
the production Archelon server support concurrent operations.

File downloads are sent as a "streaming" response, so file downloads should
start almost immediately, regardless of the size of the file. If large file
downloads take a long time to start, it might be being buffered by the Rails
server.

### Concurrent operation in the development environment

Rails disables concurrent operation when using the development environment.

Edit the "config/development.rb" file, and add the following line inside
the `Rails.application.configure` block:

```
config.allow_concurrency=true
```

## Batch Export

The batch export functionality relies on a running [Plastron] instance.

## Batch Import

See [BatchImport](docs/BatchImport.md).

## LDAP Override

By default, Archelon determines the user type for a user ("admin", "user" or
"unauthorized") using the list of Grouper groups in the `memberOf` attribute
returned from an LDAP server for that user.

The local development environment (or Docker container) can be run without
connecting to an LDAP server by setting the `LDAP_OVERRIDE` environment variable.
The `LDAP_OVERRIDE` environment variable should contain a space-separated list
of Grouper group DNs that any authenticated user should receive.

The `LDAP_OVERRIDE` environment variable only works in the `development`
Rails environment.

## About CVE-2015-9284

GitHub (or a vulnerability scanner such as "bundler-audit"), may report that
this application is vulnerable to CVE-2015-9284, due to its use of the
"omniauth" gem. More information about this vulnerability can be found at:

[https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284][cve-2015-9284]

As configured, this application uses CAS for authentication. As the application
does not use OAuth it is not vulnerable to CVE-2015-9284.

## Action Cable

The Rails "Action Cable" functionality is used to provide dynamic updates to
the GUI.

See [ActionCable](docs/ActionCable.md) for more information.

## ActiveJob and Delayed::Job

Archelon is configured to use the [Delayed::Job][delayed_job] queue adapter, via
the [delayed_job_active_record][delayed_job_active_record] gem to store jobs
in the database.

## Cron Jobs

The [delayed_cron_job][delayed_cron_job] gem is used to schedule jobs to run on
a cron-like schedule.

The "CronJob" class [app/cron_jobs/cron_job.rb](app/cron_jobs/cron_job.rb)
should be used as the superclass, and all implementations should be placed in
the "app/cron_jobs" directory.

CronJob implementations in the "app/cron_jobs" directory are automatically
scheduled when the "db:migrate" Rails task is run, via the "db:schedule_jobs"
Rake task (see [lib/tasks/jobs.rake](lib/tasks/jobs.rake)).

### Changing the schedule for a CronJob

The "Changing the schedule" section of the "delayed_cron_job" README.md file
indicates that when the "cron_expression" of a CronJob is changed, any
previously scheduled instances will need to be manually removed.

In this implementation, the "db:schedule_jobs" task removes existing CronJob
implementations from the database before adding them back in. Therefore, it
should *not* be necessary to manually delete existing CronJobs from the database
after modifying the "cron_expression" for a CronJob (as long as
"db:schedule_jobs" or "db:migrate" is run after the modification).

## React Components

### Interactive Demo

An interactive demo displaying the React components provided by the application
is available at:

http://localhost:3000/react_components

### Documenting React Components

React components are documented using "React Styleguidist"
[https://react-styleguidist.js.org/][react-styleguidist]

In the development environment, web-based interactive documentation can be
accessed by running:

```
> yarn styleguidist server
```

and then accessing the documentation at http://localhost:6060/

See the "Documenting Components" page on the "React Styleguidist" website
[https://react-styleguidist.js.org/docs/documenting][react-styleguidist-documenting],
for information about writing documentation for the React components.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations
(Apache 2.0).

[ActiveMQ]: https://github.com/umd-lib/umd-fcrepo-messaging
[blacklight]: https://github.com/projectblacklight/blacklight
[cve-2015-9284]: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
[delayed_cron_job]: https://github.com/codez/delayed_cron_job
[delayed_job]: https://github.com/collectiveidea/delayed_job
[delayed_job_active_record]: https://github.com/collectiveidea/delayed_job_active_record
[fedora]: https://duraspace.org/fedora/
[plastron]: https://github.com/umd-lib/plastron
[react-styleguidist]: https://react-styleguidist.js.org/
[react-styleguidist-documenting]: https://react-styleguidist.js.org/docs/documenting
[Solr]: https://github.com/umd-lib/umd-fcrepo-solr
[stomp]: https://stomp.github.io/
[umd-fcrepo]: https://github.com/umd-lib/umd-fcrepo
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
[boathook]: https://github.com/umd-lib/boathook
