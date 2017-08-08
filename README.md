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


## Troubleshooting

### OpenSSL::SSL::SSLError in CatalogController#index when running in development mode

For development, Archelon is typically run in conjunction with the servers provided by the [fcrepo-vagrant] multi-machine Vagrant setup. This setup uses a self-signed SSL certificate to enable HTTPS.

The "OpenSSL::SSL::SSLError" is caused by the SSL certificate not being recognized as valid by Rails. The simplest way to fix this is to create a "solrlocal.pem" file, by running the following command in the Rail project directory:

```
echo -n | openssl s_client -connect solrlocal:8984 -tls1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > solrlocal.pem
```
Then either:

a) Create an "SSL_CERT_FILE" environment variable in the terminal environment:

```
export SSL_CERT_FILE=<PATH_TO_PEM_FILE>/solrlocal.pem
```
when \<PATH_TO_PEM_FILE> is the full path to the directory containing the file, or

b) Running the Rails application prepended with the "SSL_CERT_FILE" environment variable:

```
SSL_CERT_FILE=solrlocal.pem rails server
```

**Note:** If using the second method, the Rails tests should also be run with "SSL_CERT_FILE" prepended, i.e.:

```
SSL_CERT_FILE=solrlocal.pem rake test
```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (Apache 2.0).

[archelon-vagrant]: https://github.com/umd-lib/archelon-vagrant
[fcrepo-vagrant]: https://github.com/umd-lib/fcrepo-vagrant