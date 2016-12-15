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

[archelon-vagrant]: https://github.com/umd-lib/archelon-vagrant
