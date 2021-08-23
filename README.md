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

* a Rails application providing an administrative interface to the Fedora
repository. It uses the [Blacklight][blacklight] gem for providing Solr
search functionality.
* A STOMP listener application for communicating with Plastron using the
[STOMP messaging protocol][stomp] via ActiveMQ
* an SFTP server, used to upload files for inclusion in import jobs

## Interactions with other umd-fcrepo components

Archelon interacts directly with the following umd-fcrepo components:

* ActiveMQ - Archelon communicates to Plastron using STOMP messaging mediated by
ActiveMQ queues
* Solr - Archelon communicates directly with the Solr instance in the
"umd-fcrepo-docker" stack for metadata search and retrieval
* Plastron - Archelon uses the HTTP REST interface provided by Plastron to
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

  ```
  git clone git@github.com:umd-lib/archelon.git
  cd archelon
  yarn
  bundle install
  ```

2. Set up the database:

  ```
  rails db:migrate
  ```

  **Note:** Sample "Download URL" data can be added by running
  `rails db:reset_with_sample_data`

3. Create a `.env` file from the `env_example` file and fill in appropriate
   values for the environment variables.

4. Run the web application:

  ```
  rails server
  ```

## Logging

By default, the development environment for Archelon will log at the DEBUG level,
while all other environments will log at the INFO level. To change this, set the
`RAILS_LOG_LEVEL` environment variable in your `.env` file.

In the development environment, the log will be sent to standard output and
the "log/development.log" file, as is standard in Rails application.

In production, set the "RAILS_LOG_TO_STDOUT" environment variable to "true" to
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

## Rake Tasks

### Importing Controlled Vocabularies

Archelon comes with a rake task, [vocab:import](lib/tasks/vocab.rake), to do a
bulk load of vocabulary terms from a CSV file. Run:

```
rails vocab:import[filename.csv,vocabulary]
```

where `filename.csv` is the path to a CSV file containing the vocabulary terms
to be imported, and `vocabulary` is the string name of the vocabulary to add
those terms to. This vocabulary will be created if it doesn't already exist.

The CSV file must have the following three columns:

* label
* identifier
* uri

Other columns are ignored.

The import task currently only supports creating Individuals (a.k.a. Terms),
and not Types (a.k.a. Classes).

### Importing User Public Keys

Two Rake tasks are provided for importing public keys for a user:

* ```rails user:add_public_key[cas_directory_id,public_key]```

    Adds the given public key for the user with the given CAS directory id.

    A user with the given CAS directory id must already exist.

    Note: Because of the way SSH public keys are expressed, the command
    should be enclosed in quotes, i.e.:

    ```
    rails "user:add_public_key[jsmith,ssh-rsa AAAAB3NzaC1yc2E...]"
    ```

* ```rails user:add_public_key_file[cas_directory_id,public_key_file]```

    Adds the public key from the given file for the user with the given CAS
    directory id.

    A user with the given CAS directory id must already exist.

    Relative file paths are allowed. If the file path or file name contains
    a space, the entire command should be enclosed in quotes.

    Example:

    ```
    rails user:add_public_key_file[jsmith,/home/jsmith/.ssh/id_rsa.pub]
    ```

### STOMP Listener

The "STOMP listener" application connects Archelon to ActiveMQ, and is required
for performing exports and imports. The STOMP listener application is configured
via the environment variables in the ".env" file, and run using the following
Rake task:

```
rails stomp:listen
```

### Building Docker Images

There are two Rake tasks to build and push Docker images for the Archelon
application as well as the SFTP service. The image tag version is determined
by the value of `Archelon::VERSION`. If it contains the string "dev", then
it is considered a development version as is tagged using "latest". Any other
value is used as-is.

Note that once a non-"latest" tag has been successfully pushed, further attempts
to push that same tag will fail.

```
# builds "docker.lib.umd.edu/archelon:VERSION" and "docker.lib.umd.edu/archelon-sftp:VERSION"
rails docker:build

# push to the registry
rails docker:push
```

## Docker

Archelon comes with a [Dockerfile](Dockerfile) that can be used to build a
docker image:

```
docker build -t docker.lib.umd.edu/archelon -f Dockerfile .
```

See [umd-lib/umd-fcrepo/README.md][umd-fcrepo] for information about setting up
a local development environment for Archelon using Docker.

When running locally in Docker, the Archelon database can be accessed using:

```
# Archelon database backing the Archelon Rails app
psql -U archelon -h localhost -p 5434 archelon
```

There is also a "Dockerfile.sftp" file, which sets up an SFTP server enabling
files to be uploaded to Archelon for inclusion in import jobs.

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

The batch export functionality relies on a running [Plastron]
instance.

## Batch Import

See [docs/BatchImport](docs/BatchImport.md).

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

See [docs/ActionCable.md](docs/ActionCable.md) for more information.

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

[blacklight]: https://github.com/projectblacklight/blacklight
[cve-2015-9284]: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
[fedora]: https://duraspace.org/fedora/
[plastron]: https://github.com/umd-lib/plastron
[react-styleguidist]: https://react-styleguidist.js.org/
[react-styleguidist-documenting]: https://react-styleguidist.js.org/docs/documenting
[stomp]: https://stomp.github.io/
[umd-fcrepo]: https://github.com/umd-lib/umd-fcrepo
[umd-fcrepo-docker]: https://github.com/umd-lib/umd-fcrepo-docker
