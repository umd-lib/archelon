# Archelon Development Environment

## Introduction

This page provides step-by-step instructions for setting up the following:

* fcrepo
* Plastron
* Archelon

with sample data.

The directories are set up to be usable in a Mac OS X Catalina environment,
where user-created directories may no longer be placed in the system root
directory.

See [Installing Prerequisites](Prerequisites.md) for detailed
information on prerequisites.

## Useful Resources

* [https://github.com/umd-lib/umd-fcrepo-docker](https://github.com/umd-lib/umd-fcrepo-docker)
* [https://github.com/umd-lib/plastron](https://github.com/umd-lib/plastron)
* [https://github.com/umd-lib/archelon](https://github.com/umd-lib/archelon)
* [F4: Development Environment](https://confluence.umd.edu/display/LIB/F4%3A+Development+Environment)
* [https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md](https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md)
* [https://bitbucket.org/umd-lib/umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)

## Base Directory

For the following, the base directory will be `~/git/` (where "~" is your home
directory). For example, on Mac OS X, if your username is "jsmith", the full
filepath for the base directory will be "/Users/jsmith/git/".

## Step 1: Deploy umd-fcrepo-docker stack

1. Switch to the base directory:
    ```bash
    cd ~/git
    ```
2. Clone, set up and deploy the stack according to the umd-fcrepo-docker
[README](https://github.com/umd-lib/umd-fcrepo-docker/blob/develop/README.md#quick-start)
3. Check that the following URLs are all accessible:
    * ActiveMQ admin console: <http://localhost:8161/admin>
    * Solr admin console: <http://localhost:8983/solr/#/>
    * Fuseki admin console: <http://localhost:3030/>
    * Fedora repository REST API: <http://localhost:8080/rest/>
    * Fedora repository login/user profile page: <http://localhost:8080/user/>
4. Log in to http://localhost:8080/rest, and add a "pcdm" container, using the
"Create Child Resource" panel in the right sidebar.

## Step 2: Create auth tokens for plastron and archelon

Use the following URLs to generate auth tokens for use with plastron and archelon,
respectively:

* http://localhost:8080/user/token?subject=plastron&role=fedoraAdmin
* http://localhost:8080/user/token?subject=archelon&role=fedoraAdmin
    
## Step 3: Run Plastron as a daemon

1. Clone Plastron:
    ```bash
    cd ~/git
    git clone https://github.com/umd-lib/plastron.git
    ```
2. Create directories to hold the Plastron configurations, logs, msg stores, and
binary exports:
    ```bash
    mkdir config
    mkdir logs
    mkdir msg
    mkdir exports
    ```
3. Create a Plastron configuration file `~/git/plastron/config/localhost.yml`
containing the following:
    ```yaml
    REPOSITORY:
      REST_ENDPOINT: http://localhost:8080/rest
      RELPATH: /pcdm
      AUTH_TOKEN: {auth token for plastron created in Step 2 above}
      LOG_DIR: logs/
    MESSAGE_BROKER:
      SERVER: localhost:61613
      MESSAGE_STORE_DIR: msg/
      DESTINATIONS:
        JOBS: /queue/plastron.jobs
        JOB_STATUS: /topic/plastron.jobs.status
        COMPLETED_JOBS: /queue/plastron.jobs.completed
        SYNCHRONOUS_JOBS: /queue/plastron.jobs.synchronous
    COMMANDS:
      EXPORT:
        BINARIES_DIR: exports/
    ```

    ℹ️ **Note:** For production, additional variables in the "COMMANDS" stanza
    are needed to configure the SSH private key for SFTP import/export
    operations, i.e:

    ```yaml
    COMMANDS:
      EXPORT:
        SSH_PRIVATE_KEY: /run/secrets/archelon_id
      IMPORT:
        SSH_PRIVATE_KEY: /run/secrets/archelon_id
    ```
4. Set up the Python environment to run Plastron. The following uses
virtualenv:
    ```bash
    cd ~/git/plastron
    virtualenv venv
    source venv/bin/activate
    pip install -e .
    ```
5. Run plastron as a daemon, using the new `localhost.yml` config file:
    ```bash
    plastrond -c config/localhost.yml
    ```
    ℹ️ **Note:** For troubleshooting, the plastron daemon can be run in verbose
    mode:
    ```bash
    plastrond -v -c config/localhost.yml
    ```

## Step 4: Load umd-fcrepo-sample-data

1. In a new terminal, clone the umd-fcrepo-sample-data repo:
    ```bash
    cd ~/git
    git clone git@bitbucket.org:umd-lib/umd-fcrepo-sample-data.git
    cd umd-fcrepo-sample-data
    ```
2. Activate the Plastron virtual environment:
    ```bash
    source ~/git/plastron/venv/bin/activate
    ```
3. Load the Student Newspapers data:
    ```bash
    plastron -c ~/git/plastron/config/localhost.yml mkcol -b student_newspapers/batch.yml -n 'Student Newspapers'
    plastron -c ~/git/plastron/config/localhost.yml load -b student_newspapers/batch.yml
    ```

    ℹ️ **Note:** Additional datasets are available. See the README.md file in the
    [umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
    repository for more information.

## Step 5: Setup and run Archelon

1. In a new terminal, clone the archelon repository:
    ```bash
    cd ~/git
    git clone https://github.com/umd-lib/archelon.git
    cd archelon
    ```
2. Install the Archelon dependencies:
    ```bash
    bundle install
    ```
3. Set up the database:

    ⚠️ **Warning:** The following command will destroy any data in the local
    database (if one exists).
    
    ```bash
    rails db:reset
    ```
4. Install JavaScript dependencies:
    ```bash
    yarn
    ```
5. Create a `.env` file for Archelon:
    ```bash
    cp env_example .env
    ```
6. Change the following values in `.env`:

    ℹ️ **Note:** Some values in the ".env" file are overridden in the
    ".env.development" file, which is why some variables in the ".env" file can
    remain empty.

    | Property                         | Value   |
    | -------------------------------- | ------- |
    | `FCREPO_AUTH_TOKEN`              | Value created for archelon in Step 2 |
    | `LDAP_BIND_PASSWORD`             | See the "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box. |
    | `VOCAB_LOCAL_AUTHORITY_BASE_URI` | http://vocab.lib.umd.edu/ |
    | `VOCAB_PUBLICATION_BASE_URI`     | http://localhost:3000/published_vocabularies/ |

7. Run the Archelon STOMP listener:
    ```bash
    rails stomp:listen
    ```
8. In a new terminal, run Archelon:
    ```bash
    rails server
    ```
9. Verify that Archelon is running by going to <http://localhost:3000/>

    After logging in, the Archelon home page should be displayed, and the
    "Collection" panel should display a "Student Newspapers" entry.

## Using the "postgresql" adapter with Action Cable" in the "development" environment

ℹ️ **Note:** This section describes how to set up the Archelon application to use
the postgresql adapter for both the database and Action Cable functionality.
This is intended only for those situations in which is it desirable to test such
functionality, and is not necessary to create a running system.

By default, Rails uses the `async` adapter for the development and test
environments for Action Cable functionality.

In some cases, it may be desirable to configure the development environment
to use the `postgresql` adapter for testing or troubleshooting. When using the
`postgresql` adapter for Action Cable, the database **MUST** also use Postgres
(instead of the default SQLite).

To set up the development environment, do the following:

1. Modify the "umd-fcrepo-docker/postgres/fcrepo.sh" file by changing the line:
    ```sql
    CREATE USER archelon WITH PASSWORD 'archelon';
    ```

    to:

    ```sql
    CREATE USER archelon WITH CREATEDB PASSWORD 'archelon';
    ```
2. Kill the running "umd-fcrepo-postgres" Docker container.
3. Destroy and recreate the "fcrepo-postgres-data" Docker volume
    ```bash
    docker volume rm fcrepo-postgres-data
    docker volume create fcrepo-postgres-data
    ```
4. Rebuild the "umd-fcrepo-postgres" image:
    ```bash
    docker build -t umd-fcrepo-postgres .
    ```
5. Run the "umd-fcrepo-postgres" image:
    ```bash
    docker run -d --rm -p 5432:5432 -v fcrepo-postgres-data:/var/lib/postgresql/data umd-fcrepo-postgres
    ```
6. When using the postgresql adapter for Action Cable, it is also necessary to
use Postgres for the Rails application. Switch the development environment to
use Postgres by doing the following:

    1. In `~/git/archelon/config/database.yml` file, change the `development`
    stanza to:
        ```yaml
        development:
          adapter: postgresql
          database: <%= ENV["ARCHELON_DATABASE_NAME"] %>
          username: <%= ENV["ARCHELON_DATABASE_USERNAME"] %>
          password: <%= ENV["ARCHELON_DATABASE_PASSWORD"] %>
          host: <%= ENV["ARCHELON_DATABASE_HOST"] %>
          port: <%= ENV["ARCHELON_DATABASE_PORT"] %>
          encoding: <%= ENV["ARCHELON_DATABASE_ENCODING"] %>
        ```
    2. In the `~/git/archelon/config/cable.yml` file, change the `development`
    stanza to:
        ```yaml
        development:
          adapter: postgresql
        ```
    3. Before running the Rails server, reset the database:
        ```bash
        rails db:reset
        ```
