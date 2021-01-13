# Archelon Development Environment

## Introduction

This page provides step-by-step instructions for setting up the following:

* fcrepo stack
* Plastron
* Archelon

with sample data for local development.

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

The following steps assumes are Git repositories are checked out into
subdirectories of a base directory. For example, if the base directory is
"/Users/jsmith/git/" the subdirectories will be:

```
/Users/jsmith/git/
               +- archelon/
               +- plastron/
               +- umd-fcrepo-docker/
               +- umd-fcrepo-sample-data/
               +- umd-fcrepo-webapp/
```

## Step 1: Deploy umd-fcrepo-docker stack

1.1. Switch to the base directory.

1.2. Clone and build the Docker images for the "umd-fcrepo" stack (see the
umd-fcrepo-docker [README](https://github.com/umd-lib/umd-fcrepo-docker/blob/develop/README.md#quick-start)
for canonical instructions):

```bash
git clone git@github.com:umd-lib/umd-fcrepo-webapp.git
cd umd-fcrepo-webapp
docker build -t docker.lib.umd.edu/fcrepo-webapp .

cd ..
git clone git@github.com:umd-lib/umd-fcrepo-docker.git
cd umd-fcrepo-docker

docker build -t docker.lib.umd.edu/fcrepo-activemq activemq
docker build -t docker.lib.umd.edu/fcrepo-solr-fedora4 solr-fedora4
docker build -t docker.lib.umd.edu/fcrepo-fuseki fuseki
docker build -t docker.lib.umd.edu/fcrepo-fixity fixity
docker build -t docker.lib.umd.edu/fcrepo-mail mail
```

1.3. Export the following environment variables:

```bash
export MODESHAPE_DB_PASSWORD=fcrepo
export LDAP_BIND_PASSWORD=...     # See "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box.
export JWT_SECRET=`uuidgen | shasum -a256 | cut -d' ' -f1`
```

ℹ️ **Note:** The "MODESHAPE_DB_PASSWORD" and "JWT_SECRET" are arbitrary, and
so can be different from the above, if desired. The only requirement for
"JWT_SECRET" is that it be "sufficiently long", which is accomplished by
the uuidgen command (but any "sufficiently long" string will work).

1.4. Deploy the stack:

```bash
docker stack deploy -c umd-fcrepo.yml umd-fcrepo
```

ℹ️ **Note:** For ease of deploying, you can create a .env file that exports the
required environment variables from the previous step, and source that file when
deploying:

```bash
source .env && docker stack deploy -c umd-fcrepo.yml umd-fcrepo
```

Any .env file will be ignored by Git.

1.5. Check that the following URLs are all accessible:

* ActiveMQ admin console: <http://localhost:8161/admin>
* Solr admin console: <http://localhost:8983/solr/#/>
* Fuseki admin console: <http://localhost:3030/>
* Fedora repository REST API: <http://localhost:8080/rest/>
* Fedora repository login/user profile page: <http://localhost:8080/user/>

## Step 2: Create the "pcdm" container in fcrepo

2.1. Log in at <http://localhost:8080/user/>

2.2. Go to <http://localhost:8080/rest/>

2.3. Add a "pcdm" container, using the "Create New Child Resource" panel in the
right sidebar.

## Step 3: Create auth tokens for plastron and archelon

3.1. Use the following URLs to generate auth tokens for use with Plastron and
Archelon, respectively:

* http://localhost:8080/user/token?subject=plastron&role=fedoraAdmin
* http://localhost:8080/user/token?subject=archelon&role=fedoraAdmin

## Step 4: Configure Plastron to run locally

4.1. Switch to the base directory:

```bash
cd ..
```

4.2. Clone the Plastron repository:

```bash
git clone git@github.com:umd-lib/plastron.git
```

4.3. Create directories to hold the Plastron configurations, logs, msg stores,
and binary exports:

```bash
cd plastron
mkdir logs
mkdir msg
mkdir exports
```

4.4. Create a Plastron configuration file `plastron/config/localhost.yml` file:

```bash
vi config/localhost.yml
```

containing the following:

```yaml
REPOSITORY:
    REST_ENDPOINT: http://localhost:8080/rest
    RELPATH: /pcdm
    AUTH_TOKEN: {auth token for Plastron created in Step 3.1 above}
    LOG_DIR: logs/
MESSAGE_BROKER:
    SERVER: localhost:61613
    MESSAGE_STORE_DIR: msg/
    DESTINATIONS:
      JOBS: /queue/plastron.jobs
      JOB_PROGRESS: /topic/plastron.jobs.progress
      JOB_STATUS: /queue/plastron.jobs.status
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

4.5. Set up the Python environment to run Plastron using pyenv:

```bash
pyenv install 3.6.2
pyenv virtualenv 3.6.2 plastron
pyenv local plastron
pip install -e .
```

4.6. Run plastron as a daemon, using the new `localhost.yml` config file:

```bash
plastrond -c config/localhost.yml
```

ℹ️ **Note:** For troubleshooting, the plastron daemon can be run in verbose
mode:

```bash
plastrond -v -c config/localhost.yml
```

## Step 5: Load umd-fcrepo-sample-data

5.1. In a new terminal, switch to the base directory.

5.2. Clone the umd-fcrepo-sample-data repo:

```bash
git clone git@bitbucket.org:umd-lib/umd-fcrepo-sample-data.git
cd umd-fcrepo-sample-data
```

5.3. Activate the Plastron environment:

```bash
pyenv shell plastron
```

5.4. Load the Student Newspapers data:

```bash
plastron -c ../plastron/config/localhost.yml mkcol -b student_newspapers/batch.yml -n 'Student Newspapers'
plastron -c ../plastron/config/localhost.yml load -b student_newspapers/batch.yml
```

ℹ️ **Note:** Additional datasets are available. See the README.md file in the
[umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
repository for more information.

## Step 6: Setup and run Archelon

6.1. In a new terminal, switch to the base directory.

6.2. Clone the archelon repository:

```bash
git clone git@github.com:umd-lib/archelon.git
cd archelon
```

6.3. Install the Archelon dependencies:

```bash
bundle install
```

6.4. Set up the database:

⚠️ **Warning:** The following command will destroy any data in the local
database (if one exists).

```bash
rails db:reset
```

6.5. Install JavaScript dependencies:

```bash
yarn
```

6.6. Create a `.env` file for Archelon:

```bash
cp env_example .env
```

6.7. Edit the ".env" file:

```bash
vi .env
```

and change the following values:

ℹ️ **Note:** Some values in the ".env" file are overridden in the
".env.development" file, which is why some variables in the ".env" file can
remain empty.

| Property                         | Value   |
| -------------------------------- | ------- |
| `FCREPO_AUTH_TOKEN`              | Value created for archelon in Step 3.1 |
| `LDAP_BIND_PASSWORD`             | See "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box. |
| `VOCAB_LOCAL_AUTHORITY_BASE_URI` | http://vocab.lib.umd.edu/ |
| `VOCAB_PUBLICATION_BASE_URI`     | http://localhost:3000/published_vocabularies/ |

6.8. Run the Archelon STOMP listener:

```bash
rails stomp:listen
```

6.9. In a new terminal, switch to the base directory.

6.10. Run Archelon:

```bash
cd archelon
rails server
```

6.10. Verify that Archelon is running by going to <http://localhost:3000/>

After logging in, the Archelon home page should be displayed, and the
"Collection" panel should display a "Student Newspapers" entry.

ℹ️ **Note:** If you get a "Not Authorized" page when going to
<http://localhost:3000/>, your browser is likely caching a credential from
a previous Archelon login. Go to <http://localhost:3000/> in a *private*
browser window (which should show the CAS login page). Once you log in,
refresh the "Not Authorized" page -- it should now permit entry.

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

    1. In `$BASE_DIR/archelon/config/database.yml` file, change the `development`
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

    2. In the `$BASE_DIR/archelon/config/cable.yml` file, change the `development`
    stanza to:

        ```yaml
        development:
          adapter: postgresql
        ```

    3. Before running the Rails server, reset the database:

        ```bash
        rails db:reset
        ```
