# archelon

Archelon is a Rails-based administrative interface for the Fedora 4 repository. It uses
the Blacklight gem for providing the search functionality.

## Quick Start

Requires:

* Ruby 2.6.3
* Bundler

### Setup

1. Checkout the code and install the dependencies:

  ```
  git clone git@github.com:umd-lib/archelon.git
  cd archelon
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

If you are going to run Archelon against a Solr or Fedora server that uses
self-signed SSL certificates for HTTPS, see the section [SSL setup](#ssl-setup).

See [archelon-vagrant] for running Archelon application in a Vagrant
environment.

## Archelon Development Environment Setup

To set up Archelon for development see
[docs/ArchelonDevelopmentEnvironment.md](docs/ArchelonDevelopmentEnvironment.md).

## Logging

By default, the development environment for Archelon will log at the DEBUG level,
while all other environments will log at the INFO level. To change this, set the
`RAILS_LOG_LEVEL` environment variable in your `.env` file.

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

## Docker

Archelon comes with a [Dockerfile](Dockerfile) that can be used to build a
docker image:

```
docker build -t archelon .
```

To run an instance of this image against the dev fcrepo, Solr, and IIIF servers,
and populate the database with seed data:

```
id=$(docker run -d --rm -p 3000:3000 \
    -e SOLR_URL=https://solrdev.lib.umd.edu/solr/fedora4 \
    -e FCREPO_BASE_URL=https://fcrepodev.lib.umd.edu/fcrepo/rest/ \
    -e IIIF_BASE_URL=https://iiifdev.lib.umd.edu/ \
    -e MIRADOR_STATIC_VERSION=1.2.0 \
    -e RETRIEVE_BASE_URL=http://localhost:3000/retrieve/ \
    -e LDAP_OVERRIDE=admin \
    archelon)
```

To watch the logs:

```
docker logs -f "$id"
```

To stop the running docker container:

```
docker kill "$id"
```

See the "LDAP Override" section below for more information about the
"LDAP_OVERRIDE" environment variable.

## Embedded Solr

### Initial Setup

Verify that the `.solr_wrapper.yml` file is up to date. The `collection > dir`
property in the file needs to point to a Solr core directory containing the
configuration files. In addition, the `.env` file must have its `SOLR_URL` set
to `http://localhost:8983/solr/fedora4`.

The [fedora4-core](https://bitbucket.org/umd-lib/fedora4-core) repository
includes a script to generate solr package that can be used here.

Create the Solr core as per the configuration in `.solr_wrapper.yml`:

```
bundle exec rails solr:create_collection
```

Start the solr server:

```
bundle exec rails solr:start_server
```

Load sample data included in the solr package:

```
bundle exec rails solr:rebuild_index seed_file=/path/to/sample_solr_data.yml
```

### Usage

Start the solr server:

```
bundle exec rails solr:start_server
```

Stop the solr server:

```
bundle exec rails solr:stop
```

Clean and reinstall setup:

```
bundle exec rails solr:clean
```

## File Retrieval configuration

Archelon has the ability to create one-time use URLs, which allow a Fedora
binary file to be downloaded. The random token used for the URLs, and other
information, is stored in the DownloadUrl model.

It is assumed that the URL that patrons use to retrieve the files will not
reference the Archelon server directly. Instead it is anticipated that a new IP
and Apache virtual host, which proxies back to Archelon, will be used.

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
server. For example, see the
[Passenger Phusion documentation](passenger-phusion) regarding the
"PassengerBufferResponse" setting.

### Concurrent operation in the development environment

Rails disables concurrent operation when using the development environment.

Edit the "config/development.rb" file, and add the following line to
application setting:

  ```
  config.allow_concurrency=true
  ```

## SSL setup

For development, Archelon is typically run in conjunction with the servers
provided by the [fcrepo-vagrant] multi-machine Vagrant setup. This setup uses
self-signed SSL certificates to enable HTTPS.

Rails needs to be able to verify these self-signed certificates. If it cannot,
"OpenSSL::SSL::SSLError" with an explanation "certificate verify failed" will be
displayed in the browser.

In order to avoid this error:

1. Create PEM files for both the "solrlocal" and "fcrepolocal" machines, by
   running the following commands:

  **Note:** The "solrlocal" and "fcrepolocal" servers must be running.

  ```
  echo -n \
      | openssl s_client -connect solrlocal:8984 -tls1 \
      | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
      > solrlocal.pem
  ```

  and

  ```
  echo -n \
      | openssl s_client -connect fcrepolocal:443 -tls1 \
      | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
      > fcrepolocal.pem
```

  This will create two files "solrlocal.pem" and "fcrepolocal.pem" in the
  current directory, which contain SSL certificates.

2. Combine the two "pem" files from the previous step in to a single "pem" file:

  ```
  cat solrlocal.pem fcrepolocal.pem \
      > solrlocal_and_fcrepolocal.pem
  ```

3. To use the `solrlocal_and_fcrepolocal.pem` file with Rails, set the
   `SSL_CERT_FILE` environment variable:

  ```
  export SSL_CERT_FILE=/path/to/solrlocal_and_fcrepolocal.pem
  rails server

  # or

  SSL_CERT_FILE=/path/to/solrlocal_and_fcrepolocal.pem rails server
  ```

## Batch Export

The batch export functionality relies on a running [Plastron](plastron)
instance.

## Metadata Import

See [docs/MetadataImport](docs/MetadataImport.md).

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
"omniauth" gem. More information about this vulnerablity can be found at:

[https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284][cve-2015-9284]

As configured, this application uses CAS for authenication. As the application
does not use OAuth it is not vulnerable to CVE-2015-9284.

## Action Cable

The Rails "Action Cable" functionality is used to provide dynamic updates to
the GUI.

See [docs/ActionCable.md](docs/ActionCable.md) for more information.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations
(Apache 2.0).

[archelon-vagrant]: https://github.com/umd-lib/archelon-vagrant
[cve-2015-9284]: https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
[fcrepo-vagrant]: https://github.com/umd-lib/fcrepo-vagrant
[plastron]: https://github.com/umd-lib/plastron
