# archelon

Archelon is a Rails-based search interface for the Fedora 4 repository. It uses the Blacklight gem for providing the search functionality.

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
  rake db:migrate
  ```

  **Note:** Sample "Download URL" data can be added by running `rake db:reset_with_sample_data`

3. Create a `.env` file from the `env_example` file and fill in appropriate values for the environment variables.

4. Add your directory ID to whitelist

  ```
  rake 'db:add_admin_cas_user[your_directory_id, Your Name]'
  ```

5. Run the web application:

  ```
  rails server
  ```

If you are going to run Archelon against a Solr or Fedora server that uses self-signed SSL certificates for HTTPS, see the section [SSL setup](#ssl-setup).

See [archelon-vagrant] for running Archelon application in a Vagrant environment.

## Docker

Archelon comes with a [Dockerfile](Dockerfile) that can be used to build a docker image:

```
docker build -t archelon .
```

To run an instance of this image against the dev fcrepo, Solr, and IIIF servers, and populate the database with seed data:

```
id=$(docker run -d --rm -p 3000:3000 \
    -e SOLR_URL=https://solrdev.lib.umd.edu/solr/fedora4 \
    -e FCREPO_BASE_URL=https://fcrepodev.lib.umd.edu/fcrepo/rest/ \
    -e IIIF_BASE_URL=https://iiifdev.lib.umd.edu/ \
    -e MIRADOR_STATIC_VERSION=1.2.0 \
    -e RETRIEVE_BASE_URL=http://localhost:3000/retrieve/ \
    archelon)

docker exec "$id" bundle exec rake \
    'db:add_admin_cas_user[your_directory_id, Your Name]'
```

To watch the logs:

```
docker logs -f "$id"
```

To stop the running docker container:

```
docker kill "$id"
```

## Embedded Solr

### Initial Setup

Verify that the `.solr_wrapper.yml` file is up to date. The `collection > dir` property in the file needs to point to a Solr core directory containing the configuration files. The [fedora4-core](https://bitbucket.org/umd-lib/fedora4-core/src) repository includes a script to generate solr package that can be used here.


Create the Solr core as per the configuration in `.solr_wrapper.yml`:

```
bundle exec rake solr:create_collection
```

Load sample data included in the solr package: (Start the Solr server before this step)

```
bundle exec rake solr:rebuild_index seed_file=/path/to/sample_solr_data.yml
```

### Usage
Start the solr server:

```
bundle exec rake solr:start_server
```

Stop the solr server:

```
bundle exec rake solr:stop
```

Clean and reinstall setup:

```
bundle exec rake solr:clean
```


## File Retrieval configuration

Archelon has the ability to create one-time use URLs, which allow a Fedora binary file to be downloaded. The random token used for the URLs, and other information, is stored in the DownloadUrl model.

It is assumed that the URL that patrons use to retrieve the files will not reference the Archelon server directly. Instead it is anticipated that a new IP and Apache virtual host, which proxies back to Archelon, will be used.

The base URL of the virtual host (i.e., the entire URL except for the random token, but including a trailing slash) should be set in the `RETRIEVE_BASE_URL` environment variable. This base URL should be proxied to the `<ARCHELON_SERVER_URL>/retrieve/` path.
 

## File downloads and concurrent operation

Archelon has the ability to create one-time use URLs for downloading files from Fedora. Since downloading files may take considerable time, it is necessary that the production Archelon server support concurrent operations.

File downloads are sent as a "streaming" response, so file downloads should start almost immediately, regardless of the size of the file. If large file downloads take a long time to start, it might be being buffered by the Rails server. For example, see the [Passenger Phusion documentation](passenger-phusion) regarding the "PassengerBufferResponse" setting.

### Concurrent operation in the development environment

In the development environment, there are two issues regarding concurrent operations:

 * The standard "webrick" server does not support concurrent operations
 * Rails disables concurrent operation when using the development environment.

To test concurrent operations in development mode, do the following:

1. Install the "puma" gem into the Gemfile, by adding the following line:

  ```
  gem 'puma', '~> 3.9.1'
  ```

2. Run Bundler to install the gem:

  ```
  bundle install
  ```

3. Edit the "config/application.rb" file, and add the following line to application setting:

  ```
  config.allow_concurrency=true
  ```

4. Run the following command to use the puma server:

  ```
  puma --port=3000 --workers 3
  ```

  The `--port=3000` sets the port to the webrick standard of 3000, and the `--workers 3` sets the number of concurrent workers.

## SSL setup

For development, Archelon is typically run in conjunction with the servers provided by the [fcrepo-vagrant] multi-machine Vagrant setup. This setup uses self-signed SSL certificates to enable HTTPS.

Rails needs to be able to verify these self-signed certificates. If it cannot, "OpenSSL::SSL::SSLError" with an explanation "certificate verify failed" will be displayed in the browser.

In order to avoid this error:

1. Create PEM files for both the "solrlocal" and "fcrepolocal" machines, by running the following commands:

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

  This will create two files "solrlocal.pem" and "fcrepolocal.pem" in the current directory, which contain SSL certificates.

2. Combine the two "pem" files from the previous step in to a single "pem" file:

  ```
  cat solrlocal.pem fcrepolocal.pem \
      > solrlocal_and_fcrepolocal.pem
  ```

3. To use the `solrlocal_and_fcrepolocal.pem` file with Rails, set the `SSL_CERT_FILE` environment variable:

  ```
  export SSL_CERT_FILE=/path/to/solrlocal_and_fcrepolocal.pem
  rails server
  
  # or
  
  SSL_CERT_FILE=/path/to/solrlocal_and_fcrepolocal.pem rails server
  ```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (Apache 2.0).

[archelon-vagrant]: https://github.com/umd-lib/archelon-vagrant
[fcrepo-vagrant]: https://github.com/umd-lib/fcrepo-vagrant
[passenger-phusion]: https://www.phusionpassenger.com/library/config/apache/reference/#passengerbufferresponse