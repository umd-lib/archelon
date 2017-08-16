# archelon

Archelon is a Rails-based search interface for the Fedora 4 repository. It uses the Blacklight gem for providing the search functionality.

## Quick Start

Requires:

* Ruby 2.2.4
* Bundler

### Setup

1) Checkout the code and install the dependencies:

```
> git clone git@github.com:umd-lib/archelon.git
> cd archelon
> bundle install
```

2) Set up the database:

```
> rake db:migrate
```
**Note:** Sample "Download URL" data can be added by running ```rake db:reset_with_sample_data```

3) Create a `.env` file from the `env_example` file and set the solr url to point to a working solr url.

4) Add your directory ID to whitelist

```
> rake 'db:add_admin_cas_user[your_directory_id, Your Name]'
```

### Run the web application

5) To run the web application:

```
> rails server
```

See [archelon-vagrant] for running Archelon application in a Vagrant environment.

## File Retrieval configuration

Archelon has the ability to create one-time use URLs, which allow a Fedora binary file to be downloaded. The random token used for the URLs, and other information, is stored in the DownloadUrl model.

It is assumed that the URL that patrons use to retrieve the files will not reference the Archelon server directly. Instead it is anticipated that a new IP and Apache virtual host, which proxies back to Archelon, will be used.

The base URL of the virtual host (i.e., the entire URL except for the random token) should be set up in the "RETRIEVE_BASE_URL" in the ".env" file. See the "env_example" file for an example. The base URL should be proxied to the \<ARCHELON_SERVER_URL>/retrieve path.
 

## File downloads and concurrent operation

Archelon has the ability to create one-time use URLs for downloading files from Fedora. Since downloading files may take considerable time, it is necessary that the production Archelon server support concurrent operations.

File downloads are sent as a "streaming" response, so file downloads should start almost immediately, regardless of the size of the file. If large file downloads take a long time to start, it might be being buffered by the Rails server. For example, see the [Passenger Phusion documentation](passenger-phusion) regarding the "PassengerBufferResponse" setting.

### Concurrent operation in the development environment

In the development environment, there are two issues regarding concurrent operations:

 * The standard "webrick" server does not support concurrent operations
 * Rails disables concurrent operation when using the development environment.

To test concurrent operations in development mode, do the following:

1) Install the "puma" gem into the Gemfile, by adding the following line:

```
gem 'puma', '~> 3.9.1'
```

2) Run Bundler to install the gem:

```
> bundle install
```

3) Edit the "config/application.rb" file, and add the following line to application setting:

```
    config.allow_concurrency=true
```

4) Run the following command to use the puma server:

```
> SSL_CERT_FILE=solrlocal_and_fcrepolocal.pem puma --port=3000 --workers 3
```

The "SSL_CERT_FILE=solrlocal_and_fcrepolocal.pem" is needed when using the fcrepo-vagrant environment (see below), the "--port=3000" sets the port to the webrick standard of 3000, and the "--workers 3" sets the number of concurrent workers.

## fcrepo-vagrant setup

For development, Archelon is typically run in conjunction with the servers provided by the [fcrepo-vagrant] multi-machine Vagrant setup. This setup uses self-signed SSL certificates to enable HTTPS.

Rails needs to be able to verify these self-signed certificates. If it cannot, "OpenSSL::SSL::SSLError" with an explanation "certificate verify failed" will be displayed in the browser.

In order to avoid this error:

1) Create "pem" files for both the "solrlocal" and "fcrepolocal" machines, by running the following commands:

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

2) Combine the two "pem" files from the previous step in to a single "pem" file:

```
cat solrlocal.pem fcrepolocal.pem > solrlocal_and_fcrepolocal.pem
```

To use the "solrlocal_and_fcrepolocal.pem" file with Rails either:

a) Create an "SSL_CERT_FILE" environment variable in the terminal environment:

```
export SSL_CERT_FILE=<PATH_TO_PEM_FILE>/solrlocal_and_fcrepolocal.pem
```
when \<PATH_TO_PEM_FILE> is the full path to the directory containing the file, or

b) Running the Rails application prepended with the "SSL_CERT_FILE" environment variable:

```
SSL_CERT_FILE=solrlocal_and_fcrepolocal.pem rails server
```
**Note:** If using the second method, the Rails tests should also be run with "SSL_CERT_FILE" prepended, i.e.:

```
SSL_CERT_FILE=solrlocal_and_fcrepolocal.pem rake test
```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (Apache 2.0).

[archelon-vagrant]: https://github.com/umd-lib/archelon-vagrant
[fcrepo-vagrant]: https://github.com/umd-lib/fcrepo-vagrant
[passenger-phusion]: https://www.phusionpassenger.com/library/config/apache/reference/#passengerbufferresponse