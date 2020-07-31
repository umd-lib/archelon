# Archelon Development Environment

## Introduction

This page provides step-by-step instructions for setting up the following:

* Fedora 4
* Plastron
* Archelon

with sample data.

The directories are set up to be usable in a Mac OS X "Catalina" environment,
where directories may no longer be placed in the root directory.

See [Installing Prerequisites](Prerequisites.md) for detailed
information on prerequisites.

## Useful Resources

* [https://github.com//umd-lib/fcrepo-vagrant](https://github.com//umd-lib/fcrepo-vagrant)
* [https://github.com/umd-lib/plastron](https://github.com/umd-lib/plastron)
* [https://github.com/umd-lib/archelon](https://github.com/umd-lib/archelon)
* [F4: Development Environment](https://confluence.umd.edu/display/LIB/F4%3A+Development+Environment)
* [https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md](https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md)
* [https://bitbucket.org/umd-lib/umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)

## Note on VPNs

VPN software may interfere with network communications between the
Vagrant machines and the host. If you encounter network difficulties with the
following steps, try running them with the VPN disabled, then turn the VPN
back on.

## Base Directory

For the following, the base directory will be `~/git/` (where "~" is your home
directory). For example, on Mac OS X, if your username is "jsmith", the full
filepath for the base directory will be "/Users/jsmith/git/".

## Step 1 - fedora-vagrant Setup

### Step 1.1 - Checkout fcrepo-env

1.1.1) Switch to the base directory:

```
> cd ~/git/
```

1.1.2) Clone the "fcrepo-env" repository:

```
> git clone git@bitbucket.org:umd-lib/fcrepo-env.git
```

### Step 1.2 - Checkout fedora-core

1.2.1) Switch to the base directory:

```
> cd ~/git/
```

1.2.2) Clone the "fedora4-core" repository:

```
> git clone git@bitbucket.org:umd-lib/fedora4-core.git
```

### Step 1.3 - Checkout fcrepo-vagrant

1.3.1) Switch to the base directory:

```
> cd ~/git/
```

1.3.2) Clone the "fcrepo-vagrant" respository:

```
> git clone git@github.com:umd-lib/fcrepo-vagrant
```

### Step 1.4 - Start up an instance of Postgres from umd-fcrepo-docker

1.4.1) Switch to the base directory:

```
> cd ~/git/
```

1.4.2) Clone the "umd-fcrepo-docker" repository:

```
> git clone https://github.com/umd-lib/umd-fcrepo-docker.git
```

1.4.3) Change directory to "~/git/umd-fcrepo-docker":

```
> cd ~/git/umd-fcrepo-docker/postgres
```

1.4.4) Create a Docker volume named "fcrepo-postgres-data":

```
> docker volume create fcrepo-postgres-data
```

1.4.5) Build the "umd-fcrepo-postgres" image:

```
> docker build -t umd-fcrepo-postgres .
```

1.4.6) Run the "umd-fcrepo-postgres" image:

```
> docker run -p 5432:5432 -v fcrepo-postgres-data:/var/lib/postgresql/data umd-fcrepo-postgres
```

----

**Note:** If you want to run "umd-fcrepo-postgres" as a daemon (and destroyed
when the container exits), use:

```
> docker run -d --rm -p 5432:5432 -v fcrepo-postgres-data:/var/lib/postgresql/data umd-fcrepo-postgres
```

----

### Step 1.5 - Add "fcrepolocal" and "solrlocal" to /etc/hosts

1.5.1) Run the following commands to add "fcrepolocal" and "solrlocal" hosts to
       /etc/hosts:

```
> sudo echo "192.168.40.10 fcrepolocal" >> /etc/hosts
> sudo echo "192.168.40.11 solrlocal" >> /etc/hosts
```

### Step 1.6 - Start fcrepo-vagrant

1.6.1) Switch to the "~/git/fcrepo-vagrant" directory:

```
> cd ~/git/fcrepo-vagrant
```

1.6.2) Start the Solr and fcrepo Vagrant machines:

```
> vagrant up
```

### Step 1.7 - Verify that fcrepo-vagrant is running

In a web browser, go to each of the following URLs:

* Application Landing Page: [https://fcrepolocal/](https://fcrepolocal/)
* Log in: [https://fcrepolocal/user](https://fcrepolocal/user)
* Fedora REST interface: [https://fcrepolocal/fcrepo/rest](https://fcrepolocal/fcrepo/rest)
* Solr Admin interface: [http://solrlocal:8983/solr](http://solrlocal:8983/solr)
* ActiveMQ Admin Interface: [https://fcrepolocal/activemq/admin](https://fcrepolocal/activemq/admin)

## Step 2 - Setup and Run Plastron as a daemon

### 2.1) Checkout "plastron" repostory

2.1.1) Switch to the base directory:

```
> cd ~/git/
```

2.1.2) Clone the "plastron" repository:

```
> git clone https://github.com/umd-lib/plastron.git
```

### 2.2) Configure plastron with fcrepo SSL certificates

2.2.1) Switch to the "~/git/fcrepo-vagrant/" directory:

```
> cd ~/git/fcrepo-vagrant/
```

2.2.2) Run the "clientcert" script:

```
> bin/clientcert batchloader ~/git/plastron/batchloader
```

2.2.3) Switch to the "~/git/plastron/" directory:

```
> cd ~/git/plastron/
```

2.2.4) Copy the "~/git/fcrepo-vagrant/dist/fcrepo/ssl/crt/fcrepolocal.crt" as
       "repository.pem":

```
> cp ~/git/fcrepo-vagrant/dist/fcrepo/ssl/crt/fcrepolocal.crt ~/git/plastron/repository.pem
```

### 2.3) Create the Plastron daemon configuration file

2.3.1) Switch to the "~/git/plastron" directory:

```
> cd ~/git/plastron
```

2.3.2) Create a directory to hold the "plastron" logs, msg stores, and
       binary exports:

```
> mkdir logs
> mkdir msg
> mkdir exports
```

2.3.3) Create a "daemon-plastron.yml" file:

```
> vi daemon-plastron.yml
```

and add the following lines:

```
REPOSITORY:
  REST_ENDPOINT: https://fcrepolocal/fcrepo/rest
  RELPATH: /pcdm
  CLIENT_CERT: batchloader.pem
  CLIENT_KEY: batchloader.key
  SERVER_CERT: repository.pem
  LOG_DIR: logs/
MESSAGE_BROKER:
  SERVER: fcrepolocal:61613
  MESSAGE_STORE_DIR: msg/
  DESTINATIONS:
    JOBS: /queue/plastron.jobs
    JOB_STATUS: /topic/plastron.jobs.status
    COMPLETED_JOBS: /queue/plastron.jobs.completed
    SYNCHRONOUS_JOBS: /queue/plastron.jobs.synchronous
COMMANDS:
```

----
**Note:** For production, additional variables in the "COMMANDS"
stanza are needed to configure the SSH private key for STFP
import/export operations, i.e:

```
COMMANDS:
  EXPORT:
    SSH_PRIVATE_KEY: /run/secrets/archelon_id
  IMPORT:
    SSH_PRIVATE_KEY: /run/secrets/archelon_id
```
----

### 2.4) Run Plastron

Set up the Python environment to run Plastron. The following uses "virtualenv".

2.4.1) Switch to the "~/git/plastron" directory:

```
> cd ~/git/plastron
```

2.4.2) Create a virtual environment named "venv":

```
> virtualenv venv
```

2.4.3) Activate the virtual environment:

```
> source venv/bin/activate
```

2.4.4) Install the requirements:

```
> pip install -e .
```

2.4.5) Run plastron as a daemon, using the "daemon-plastron.yml" file:

```
> plastrond -c daemon-plastron.yml
```

----

**Note:** For troubleshooting, the plastron daemon can be run in "verbose" mode:

```
> plastrond --verbose -c daemon-plastron.yml
```

----

## Step 3 - Load umd-fcrepo-sample-data

### 3.1) Load the "umd-fcrepo-sample-data" using the following steps:

3.1.1) Create a new terminal.

3.1.2) Switch to the base directory:

```
> cd ~/git/
```

3.1.3) Clone the "umd-fcrepo-sample-data" repository:

```
> git clone git@bitbucket.org:umd-lib/umd-fcrepo-sample-data.git
```

3.1.4) Switch to the "~/git/umd-fcrepo-sample-data" directory:

```
> cd ~/git/umd-fcrepo-sample-data
```

3.1.5) Copy the server and client SSL certificates from fcrepo:

```
> ./setup_fcrepo.sh
```

3.1.6) Activate the Plastron virtual environment:

```
> source ~/git/plastron/venv/bin/activate
```

3.1.7) Load the Student Newspapers data:

```
> plastron -r repo.yml mkcol -b student_newspapers/batch.yml -n 'Student Newspapers'
> plastron -r repo.yml load -b student_newspapers/batch.yml
```

----

**Note:** Additional datasets are available. See the README.md file in the
[umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
repository.

----

## Step 4 - Setup and run Archelon

### 4.1) Checkout "archelon" repostory

4.1.1) Create a new terminal.

4.1.2) Switch to the base directory:

```
> cd ~/git/
```

4.1.2) Clone the "archelon" repository:

```
> git clone https://github.com/umd-lib/archelon.git
```

### 4.2) Setup the Archelon dependencies

The following assumes that "rvm" is being used.

4.2.1) Switch to the "~/git/archelon/" directory:

```
> cd ~/git/archelon/
```

4.2.2) Install the dependencies:

```
> bundle install
```

4.2.3) Set up the database:

----

**Note:** The following command will destroy any data in the local database
(if one exists).

----

```
> rails db:reset
```

4.2.4) Run "yarn" to install JavaScript dependencies:

```
> yarn
```

### 4.3) Configure Archelon with fcrepo SSL certificates

4.3.1) Switch to the "~/git/fcrepo-vagrant/" directory:

```
> cd ~/git/fcrepo-vagrant/
```

4.3.2) Run the "clientcert" script:

```
> bin/clientcert batchloader ~/git/archelon/batchloader
```

4.3.3) Switch to the "~/git/archelon/" directory:

```
> cd ~/git/archelon/
```

----

**Note:** The "batchloader.jks" and "batchloader.p12" files added by the "clientcert"
script are not needed and can be removed:

```
> rm batchloader.jks batchloader.p12
```

----

### 4.4) Configure Archelon

4.4.1) Switch to the "~/git/archelon/" directory:

```
> cd ~/git/archelon/
```

4.4.2) Copy the "env_example" file to ".env":

```
> cp env_example .env
```

4.4.5) Edit the ".env":

```
> vi .env
```

changing the following:

----

**Note:** Some values in the ".env" file are overridden in the
".env.development" file, which is why some variables in the ".env" file can
remain empty.

----

| Property                       | Value   |
| ------------------------------ | ------- |
| LDAP_BIND_PASSWORD             | See the "FCRepo Directory LDAP AuthDN" in the "Identites" document on the shared SSDR Google Drive. |
| FCREPO_CLIENT_CERT             | batchloader.pem |
| FCREPO_CLIENT_KEY              | batchloader.key |
| VOCAB_LOCAL_AUTHORITY_BASE_URI | http://vocab.lib.umd.edu/ |
| VOCAB_PUBLICATION_BASE_URI     | http://localhost:3000/published_vocabularies/ |

## 4.5) Run the Archelon STOMP listener

4.5.1) Switch to the "~/git/archelon/" directory:

```
> cd ~/git/archelon/
```

4.5.2) Run the Archelon STOMP listener using the following command:

```
> rails stomp:listen
```

## 4.6) Run Archelon

4.6.1) Create a new terminal.

4.6.2) Switch to the "~/git/archelon/" directory:

```
> cd ~/git/archelon/
```

4.6.3) Run Archelon using the following command:

```
> rails server
```

4.6.4) Verify that Archelon is running by going to:

[http://localhost:3000/](http://localhost:3000/)

After logging in, the Archelon home page should be displayed. The "Collection"
panel should display a "Student Newspapers" entry.

## Using the "postgresql" adapter with Action Cable" in the "development" environment

----

**Note:** This section describes how to set up the Archelon application to use
the "postgresql" adapter for both the database and Action Cable functionality.
This is intended only for those situations in which is it desirable to test such
functionality, and is not necessary to create a running system.

----

By default, Rails uses the "async" adapter for the "development" and "test"
environments for Action Cable functionality.

In some cases, it may be desirable to configure the "development" environment
to use the "postgresql" adapter for testing or troubleshooting. When using the
"postgresql" adapter for Action Cable, the database must also use Postgres
(instead of the default Sqlite).

To set up the "development" environment, do the following:

1) Modify the "umd-fcrepo-docker/postgres/fcrepo.sh" file by changing the line:

```
CREATE USER archelon WITH PASSWORD 'archelon';
```

to

```
CREATE USER archelon WITH CREATEDB PASSWORD 'archelon';
```

2) Kill the running "umd-fcrepo-postgres" Docker container.

3) Destroy and recreate the "fcrepo-postgres-data" Docker volume

```
> docker volume rm fcrepo-postgres-data
> docker volume create fcrepo-postgres-data
```

4) Rebuild the "umd-fcrepo-postgres" image:

```
> docker build -t umd-fcrepo-postgres .
```

5) Run the "umd-fcrepo-postgres" image:

```
> docker run -d --rm -p 5432:5432 -v fcrepo-postgres-data:/var/lib/postgresql/data umd-fcrepo-postgres
```

6) When using the "postgresql" adapter for Action Cable, it is also necessary
   to use Postgres for the Rails application. Switch the "development"
   environment to use Postgres by doing the following:

      a) In the "archelon" Rails application, edit the "config/database.yml" file,
         changing the "development" stanza to:

      ```
      development:
        <<: *default
        adapter: postgresql
        database: <%= ENV["ARCHELON_DATABASE_NAME"] %>
        username: <%= ENV["ARCHELON_DATABASE_USERNAME"] %>
        password: <%= ENV["ARCHELON_DATABASE_PASSWORD"] %>
        host: <%= ENV["ARCHELON_DATABASE_HOST"] %>
        port: <%= ENV["ARCHELON_DATABASE_PORT"] %>
        encoding: <%= ENV["ARCHELON_DATABASE_ENCODING"] %>
      ```

      b) In the "config/cable.yml" file, change the "development" stanza to:

      ```
      development:
        adapter: postgresql
      ```

      c) Before running the Rails server, reset the database:

      ```
      > rails db:reset
      ```
