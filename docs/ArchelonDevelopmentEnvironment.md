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

* [https://github.com/umd-lib/umd-fcrepo](https://github.com/umd-lib/umd-fcrepo)
* [https://github.com/umd-lib/umd-fcrepo-docker](https://github.com/umd-lib/umd-fcrepo-docker)
* [https://github.com/umd-lib/plastron](https://github.com/umd-lib/plastron)
* [https://github.com/umd-lib/archelon](https://github.com/umd-lib/archelon)
* [F4: Development Environment](https://confluence.umd.edu/display/LIB/F4%3A+Development+Environment)
* [https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md](https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md)
* [https://bitbucket.org/umd-lib/umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)

## Step 1: Clone the "umd-fcrepo" repository

1.1) Clone the "umd-fcrepo" repository and its submodules:

```bash
git clone --recurse-submodules git@github.com:umd-lib/umd-fcrepo.git
```

1.2) Switch into the "umd-fcrepo" directory:

```bash
cd umd-fcrepo
```

The "umd-fcrepo" directory will be considered the "base directory" for the
following steps.

1.3) (**Optional**) Build and deploy the "umd-camel-processors" jar to the
Maven Nexus:

```bash
cd umd-camel-processors
mvn clean deploy
cd ..
```

ℹ️ **Note:** Publishing to the Nexus means that it will now be used by everyone
as the "latest" version of the jar.

## Step 2: Deploy umd-fcrepo-docker stack

2.1. Switch to the base directory.

2.2. Switch to "umd-fcrepo-webapp" and build the Docker images for the
"umd-fcrepo" stack (see the
umd-fcrepo-docker [README](https://github.com/umd-lib/umd-fcrepo-docker/blob/develop/README.md#quick-start)
for canonical instructions):

```bash
cd umd-fcrepo-webapp
docker build -t docker.lib.umd.edu/fcrepo-webapp .

cd ../umd-fcrepo-messaging
docker build -t docker.lib.umd.edu/fcrepo-messaging .

cd ../umd-fcrepo-solr
docker build -t docker.lib.umd.edu/fcrepo-solr-fedora4 .

cd ../umd-fcrepo-docker

docker build -t docker.lib.umd.edu/fcrepo-fuseki fuseki
docker build -t docker.lib.umd.edu/fcrepo-fixity fixity
docker build -t docker.lib.umd.edu/fcrepo-mail mail
```

2.3. Export the following environment variables:

```bash
export MODESHAPE_DB_PASSWORD=fcrepo
export LDAP_BIND_PASSWORD=...     # See "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box.
export JWT_SECRET=`uuidgen | shasum -a256 | cut -d' ' -f1`
```

ℹ️ **Note:** The "MODESHAPE_DB_PASSWORD" and "JWT_SECRET" are arbitrary, and
so can be different from the above, if desired. The only requirement for
"JWT_SECRET" is that it be "sufficiently long", which is accomplished by
the uuidgen command (but any "sufficiently long" string will work).

2.4. Deploy the stack:

```bash
docker stack deploy --with-registry-auth -c umd-fcrepo.yml umd-fcrepo
```

ℹ️ **Note:** For ease of deploying, you can create a .env file that exports the
required environment variables from the previous step, and source that file when
deploying:

```bash
source .env && docker stack deploy --with-registry-auth -c umd-fcrepo.yml umd-fcrepo
```

Any .env file will be ignored by Git.

2.5. Check that the following URLs are all accessible:

* ActiveMQ admin console: <http://fcrepo-local:8161/admin>
* Solr admin console: <http://fcrepo-local:8983/solr/#/>
* Fuseki admin console: <http://fcrepo-local:3030/>
* Fedora repository REST API: <http://fcrepo-local:8080/fcrepo/rest/>
* Fedora repository login/user profile page: <http://fcrepo-local:8080/fcrepo/user/>

## Step 3: Create collection container in fcrepo

Items can be loaded into fcrepo using either a "flat" or "hierarchical"
structure.

In a "flat" structure, all the resources are loaded as children of the
"RELPATH" in the Plastron configuration (typically "/pcdm"). Items and
pages are siblings instead of parent-child items. The "collection" URI is
a separate resource with no children.

In a "hierarchical" structure, the resources are placed as children under
the collection URI, with a hierachical parent-child layout.

Older datasets in fcrepo use the "flat" structure. Future datasets will be
loaded using the "hierarchical" structure.

Choose one of the two structures for loading the data, based on your
development needs, and follow the corresponding steps.

For hierarchical structure, see the "Proposed Initial List of Collections"
section in [https://confluence.umd.edu/display/LIB/Fedora%3A+Repository+Structure#][fcrepo-repository-structure]
for the proposed relative path for each collection. For example, the proposed
relative path for the "Student Newspapers" collection (used below) is
"/dc/2016/1".

### Step 3 - Flat structure

3.1. Log in at <http://fcrepo-local:8080/fcrepo/user/>

3.2. Go to <http://fcrepo-local:8080/fcrepo/rest/>

3.3. Add a "pcdm" container, using the "Create New Child Resource" panel in the
right sidebar.

### Step 3 - Hierarchical Structure

3.1. Log in at <http://fcrepo-local:8080/fcrepo/user/>

3.2. Go to <http://fcrepo-local:8080/fcrepo/rest/>

3.3. Add a "/dc/2016/1" container, using the "Create New Child Resource" panel
in the right sidebar.

3.4. Provide the name "Student Newspapers" to the "/dc/2016/1" container (and
identify it as a "pcdm:Collection") by entering the following in the
"Update Properties" panel in the right sidebar and left-clicking the
"Update" button:

```
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX pcdm: <http://pcdm.org/models#>
DELETE {} INSERT { <> a pcdm:Collection; dcterms:title "Student Newspapers" } WHERE {}
```

## Step 4: Create auth tokens for plastron and archelon

4.1. Use the following URLs to generate auth tokens for use with Plastron and
Archelon, respectively:

* http://fcrepo-local:8080/fcrepo/user/token?subject=plastron&role=fedoraAdmin
* http://fcrepo-local:8080/fcrepo/user/token?subject=archelon&role=fedoraAdmin

## Step 5: Setup and run Plastron locally

5.1. Switch to the base directory:

```bash
cd ..
```

5.2. Create directories to hold the Plastron configurations, logs, msg stores,
and binary exports:

```bash
cd plastron
mkdir logs
mkdir msg
mkdir exports
```

5.3. Create a Plastron configuration file `plastron/config/fcrepo-local.yml`
file:

```bash
vi config/fcrepo-local.yml
```

containing the following:

```yaml
REPOSITORY:
    REST_ENDPOINT: http://fcrepo-local:8080/fcrepo/rest
    RELPATH: /pcdm
    AUTH_TOKEN: {auth token for Plastron created in Step 4.1 above}
    LOG_DIR: logs/
MESSAGE_BROKER:
    SERVER: fcrepo-local:61613
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

----

5.4. Create a virtual environment named "venv":

```
> virtualenv venv
```

5.5. Activate the virtual environment:

```
> source venv/bin/activate
```

5.6. Set up the Python environment to run Plastron using pyenv:

```bash
pyenv install 3.6.12
pyenv virtualenv 3.6.12 plastron
pyenv local plastron
pip install -e .
```

5.7. Run plastron as a daemon, using the new `fcrepo-local.yml` config file:

```bash
plastrond -c config/fcrepo-local.yml
```

ℹ️ **Note:** For troubleshooting, the plastron daemon can be run in verbose
mode:

```bash
plastrond -v -c config/fcrepo-local.yml
```

## Step 6: Load umd-fcrepo-sample-data

Follow the appropriate steps, based on whether the "flat" or "hierarchical"
structure is being used.

### Step 6 - Flat Structure

6.1.In a new terminal, switch to the base directory.

6.2. Clone the umd-fcrepo-sample-data repository:

```bash
git clone git@bitbucket.org:umd-lib/umd-fcrepo-sample-data.git
cd umd-fcrepo-sample-data
```

6.3. Activate the Plastron environment:

```bash
pyenv shell plastron
```

6.4. Load the Student Newspapers data:

```bash
plastron -c ../plastron/config/fcrepo-local.yml mkcol -b student_newspapers/batch.yml -n 'Student Newspapers'
plastron -c ../plastron/config/fcrepo-local.yml load -b student_newspapers/batch.yml
```

ℹ️ **Note:** Additional datasets are available. See the README.md file in the
[umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
repository for more information.

### Step 6 - Hierachical Structure

6.1. In a new terminal, switch to the base directory.

6.2. Clone the umd-fcrepo-sample-data repository:

```bash
git clone git@bitbucket.org:umd-lib/umd-fcrepo-sample-data.git
cd umd-fcrepo-sample-data
```

6.3. Activate the Plastron environment:

```bash
pyenv shell plastron
```

6.4. Create a "plastron-student_newspapers-load.yml" configuration file:

```bash
vi plastron-student_newspapers-load.yml
```

using the following template:

```
REPOSITORY:
    REST_ENDPOINT: http://fcrepo-local:8080/fcrepo/rest
    STRUCTURE: hierarchical
    RELPATH: {COLLECTION_RELPATH}
    AUTH_TOKEN: {PLASTRON_AUTH_TOKEN}
    LOG_DIR: logs/
```

where {PLASTRON_AUTH_TOKEN} is the Plastron token from Step 4.1 above, and
 {COLLECTION_RELPATH} is the relative path of the collection. For the
 "Student Newspapers"  collection (see explanation in Step 3), the
 {COLLECTION_RELPATH} is "/dc/2016/1", so the configuration file would be:

```
REPOSITORY:
    REST_ENDPOINT: http://fcrepo-local:8080/fcrepo/rest
    STRUCTURE: hierarchical
    RELPATH: /dc/2016/1
    AUTH_TOKEN: {PLASTRON_AUTH_TOKEN}
    LOG_DIR: logs/
```

where {PLASTRON_AUTH_TOKEN} is the Plastron token from Step 4.1 above.

6.5. Edit the "student_newspapers/batch.yml" file:

```bash
vi student_newspapers/batch.yml
```

and change the "COLLECTION" value to match the full collection URI path, which
consists of a base server URL plus the {COLLECTION_RELPATH} from the
previous step. For example, in the local development enviroment, the base server
URL is "http://fcrepo-local:8080/fcrepo/rest", and the collection relative path
is "/dc/2016/1", making the full collection URI
"http://fcrepo-local:8080/fcrepo/rest/dc/2016/1":

```
COLLECTION: http://fcrepo-local:8080/fcrepo/rest/dc/2016/1
```

6.6. Load the Student Newspapers data:

```bash
plastron -c plastron-student_newspapers-load.yml load -b student_newspapers/batch.yml
```

ℹ️ **Note:** Additional datasets are available. See the README.md file in the
[umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
repository for more information.

## Step 7: Setup and run Archelon

7.1. In a new terminal, switch to the base directory.

7.2. Switch to the "archelon" subdirectory

```bash
cd archelon
```

7.3. Install the Archelon dependencies:

```bash
bundle install
```

7.4. Set up the database:

⚠️ **Warning:** The following command will destroy any data in the local
database (if one exists).

```bash
rails db:reset
```

7.5. Install JavaScript dependencies:

```bash
yarn
```

7.6. Create a `.env` file for Archelon:

```bash
cp env_example .env
```

7.7. Edit the ".env" file:

```bash
vi .env
```

and change the following values:

ℹ️ **Note:** Some values in the ".env" file are overridden in the
".env.development" file, which is why some variables in the ".env" file can
remain empty.

| Property                         | Value   |
| -------------------------------- | ------- |
| `FCREPO_AUTH_TOKEN`              | Value created for archelon in Step 4.1 |
| `LDAP_BIND_PASSWORD`             | See "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box. |
| `VOCAB_LOCAL_AUTHORITY_BASE_URI` | http://vocab.lib.umd.edu/ |
| `VOCAB_PUBLICATION_BASE_URI`     | http://localhost:3000/published_vocabularies/ |

7.8. Run the Archelon STOMP listener:

```bash
rails stomp:listen
```

7.9. In a new terminal, switch to the base directory.

7.10. Run Archelon:

```bash
cd archelon
rails server
```

7.11. Verify that Archelon is running by going to <http://localhost:3000/>

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

1. Stop the Archelon STOMP listener and applicaton, if running.

2. In the "$BASE_DIR/archelon" directory, create a ".env.local" file:

```bash
vi .env.local
```

with the following contents:

```
ARCHELON_DATABASE_ADAPTER=postgresql
ARCHELON_DATABASE_NAME=archelon
ARCHELON_DATABASE_HOST=localhost
ARCHELON_DATABASE_PORT=5434
ARCHELON_DATABASE_USERNAME=postgres
ARCHELON_DATABASE_PASSWORD=postgres
  ```

3. In the `$BASE_DIR/archelon/config/cable.yml` file:

```bash
vi config/cable.yml
```

change the `development` stanza to:

```yaml
development:
  adapter: postgresql
```

4. Reset the Archelon database (this is necessary because the Postgres database
is now being used, instead of sqlite):

```bash
rails db:reset
```

5. Restart the Archelon STOMP listener and applicaton.

---
[fcrepo-repository-structure]: https://confluence.umd.edu/display/LIB/Fedora%3A+Repository+Structure
