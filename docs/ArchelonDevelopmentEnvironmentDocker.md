# Archelon Development Environment - Docker

## Introduction

This page provides step-by-step instructions for setting up the following:

* fcrepo stack
* Plastron
* Archelon

with sample data for local development, using Docker.

## Useful Resources

* [https://github.com/umd-lib/umd-fcrepo](https://github.com/umd-lib/umd-fcrepo)
* [https://github.com/umd-lib/umd-fcrepo-docker](https://github.com/umd-lib/umd-fcrepo-docker)
* [https://github.com/umd-lib/plastron](https://github.com/umd-lib/plastron)
* [https://github.com/umd-lib/archelon](https://github.com/umd-lib/archelon)
* [F4: Development Environment](https://confluence.umd.edu/display/LIB/F4%3A+Development+Environment)
* [https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md](https://github.com/umd-lib/plastron/blob/develop/docs/daemon.md)
* [https://bitbucket.org/umd-lib/umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)

## Step 1: Add "fcrepo-local" alias

**Note:** This step only needs to be done once on the host machine.

1.1) Edit the "/etc/hosts" file:

```bash
> sudo vi /etc/hosts
```

and add an "fcrepo-local" alias to the "127.0.0.1" entry:

```
127.0.0.1       localhost fcrepo-local
```

## Step 2: Clone the "umd-fcrepo" repository

2.1) Clone the "umd-fcrepo" repository and its submodules:

```bash
> git clone --recurse-submodules git@github.com:umd-lib/umd-fcrepo.git
```

2.2) Switch into the "umd-fcrepo" directory:

```bash
> cd umd-fcrepo
```

The "umd-fcrepo" directory will be considered the "base directory" for the
following steps.

2.3) (**Optional**) Build and deploy the "umd-camel-processors" jar to the
Maven Nexus:

```bash
> cd umd-camel-processors
> mvn clean deploy
> cd ..
```

ℹ️ **Note:** Publishing to the Nexus means that it will now be used by everyone
as the "latest" version of the jar.

## Step 3: Deploy umd-fcrepo-docker stack

3.1) Switch to the base directory.

3.2) Switch to "umd-fcrepo-webapp" and build the Docker images for the
"umd-fcrepo" stack (see the
umd-fcrepo-docker [README](https://github.com/umd-lib/umd-fcrepo-docker/blob/develop/README.md#quick-start)
for canonical instructions):

```bash
> cd umd-fcrepo-webapp
> docker build -t docker.lib.umd.edu/fcrepo-webapp .

> cd ../umd-fcrepo-messaging
> docker build -t docker.lib.umd.edu/fcrepo-messaging .

> cd ../umd-fcrepo-solr
> docker build -t docker.lib.umd.edu/fcrepo-solr-fedora4 .

> cd ../umd-fcrepo-docker

> docker build -t docker.lib.umd.edu/fcrepo-fuseki fuseki
> docker build -t docker.lib.umd.edu/fcrepo-fixity fixity
> docker build -t docker.lib.umd.edu/fcrepo-mail mail
```

3.3) Export the following environment variables:

```bash
export MODESHAPE_DB_PASSWORD=fcrepo
export LDAP_BIND_PASSWORD=...     # See "FCRepo Directory LDAP AuthDN" in the "Identities" document on Box.
export JWT_SECRET=`uuidgen | shasum -a256 | cut -d' ' -f1`
```

ℹ️ **Note:** The "MODESHAPE_DB_PASSWORD" and "JWT_SECRET" are arbitrary, and
so can be different from the above, if desired. The only requirement for
"JWT_SECRET" is that it be "sufficiently long", which is accomplished by
the uuidgen command (but any "sufficiently long" string will work).

3.4) Deploy the stack:

```bash
> docker stack deploy --with-registry-auth -c umd-fcrepo.yml umd-fcrepo
```

ℹ️ **Note:** For ease of deploying, you can create a .env file that exports the
required environment variables from the previous step, and source that file when
deploying:

```bash
> source .env && docker stack deploy --with-registry-auth -c umd-fcrepo.yml umd-fcrepo
```

Any .env file will be ignored by Git.

3.5) Check that the following URLs are all accessible:

* ActiveMQ admin console: <http://fcrepo-local:8161/admin>
* Solr admin console: <http://fcrepo-local:8983/solr/#/>
* Fuseki admin console: <http://fcrepo-local:3030/>
* Fedora repository REST API: <http://fcrepo-local:8080/fcrepo/rest/>
* Fedora repository login/user profile page: <http://fcrepo-local:8080/fcrepo/user/>

## Step 4: Create collection container in fcrepo

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

### Step 4 - Flat structure

4.1) Log in at <http://fcrepo-local:8080/fcrepo/user/>

4.2) Go to <http://fcrepo-local:8080/fcrepo/rest/>

4.3) Add a "pcdm" container, using the "Create New Child Resource" panel in the
right sidebar.

### Step 4 - Hierarchical Structure

4.1) Log in at <http://fcrepo-local:8080/fcrepo/user/>

4.2) Go to <http://fcrepo-local:8080/fcrepo/rest/>

4.3) Add a "/dc/2016/1" container, using the "Create New Child Resource" panel
in the right sidebar.

4.4) Provide the name "Student Newspapers" to the "/dc/2016/1" container (and
identify it as a "pcdm:Collection") by entering the following in the
"Update Properties" panel in the right sidebar and left-clicking the
"Update" button:

```
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX pcdm: <http://pcdm.org/models#>
DELETE {} INSERT { <> a pcdm:Collection; dcterms:title "Student Newspapers" } WHERE {}
```

## Step 5: Create auth tokens for plastron and archelon

5.1) Use the following URL to generate an auth token for use with Archelon:

* http://fcrepo-local:8080/fcrepo/user/token?subject=archelon&role=fedoraAdmin

## Step 6: Configure the Plastron Docker stack

6.1) Switch to the Plastron directory:

```bash
> cd ../plastron
```

6.2) Build the "docker.lib.umd.edu/plastrond" Docker image:

```bash
> docker build -t docker.lib.umd.edu/plastrond:latest -f Dockerfile .
```

6.3) Create a private/public key pair for communicating with Archelon:

```bash
> ssh-keygen -q -t rsa -N '' -f archelon_id
```

This will generate two files, "archelon_id" and "archelon_id.pub".

6.4) Edit the "docker-plastron.yml" file:

```bash
> vi docker-plastron.yml
```

changing the "JWT_SECRET" to the JWT_SECRET from Step 3.3.

6.5) Deploy the "plastrond" Docker stack:

```bash
> docker stack deploy -c docker-compose.yml plastrond
```

## Step 7: Load umd-fcrepo-sample-data

7.1) Use "docker exec" to access the Plastron container, where
{PLASTRON CONTAINER ID} is the Plastron container id:

```bash
> docker exec -it {PLASTRON CONTAINER ID} /bin/bash
```

7.2) Inside the "plastron" Docker container, Install "git" and "vim":

```bash
plastron> apt update
plastron> apt install -y git vim
```

7.3) Switch to the "/opt" directory:

```bash
plastron> cd /opt
```

7.4) Clone the "umd-fcrepo-sample-data" repository, replacing {USER} with your Bitbucket username:

```bash
plastron> git clone https://{USER}@bitbucket.org/umd-lib/umd-fcrepo-sample-data.git
```

Follow the appropriate steps, based on whether the "flat" or "hierarchical"
structure is being used.

### Flat Structure

7.5) Load the "Student Newpapers" sample data:

```bash
plastron> cd umd-fcrepo-sample-data
plastron> plastron -c /etc/plastrond.yml mkcol -b student_newspapers/batch.yml -n 'Student Newspapers'
plastron> plastron -c /etc/plastrond.yml load -b student_newspapers/batch.yml
```

7.6) Exit from the "plastron" container and switch back to the base directory:

```bash
plastron> exit
> cd ..
```

### Hierachical Structure

7.5) Create a "plastron-student_newspapers-load.yml" configuration file:

```bash
plastron> vi plastron-student_newspapers-load.yml
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

where {PLASTRON_AUTH_TOKEN} is the Plastron token from Step 5.1 above, and
{COLLECTION_RELPATH} is the relative path of the collection. For the
"Student Newspapers"  collection (see explanation in Step 4), the
{COLLECTION_RELPATH} is "/dc/2016/1", so the configuration file would be:

```
REPOSITORY:
    REST_ENDPOINT: http://fcrepo-local:8080/fcrepo/rest
    STRUCTURE: hierarchical
    RELPATH: /dc/2016/1
    AUTH_TOKEN: {PLASTRON_AUTH_TOKEN}
    LOG_DIR: logs/
```

where {PLASTRON_AUTH_TOKEN} is the Plastron token from Step 5.1 above.

7.6) Edit the "student_newspapers/batch.yml" file:

```bash
plastron> vi student_newspapers/batch.yml
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

7.7) Load the Student Newspapers data:

```bash
plastron> plastron -c plastron-student_newspapers-load.yml load -b student_newspapers/batch.yml
```

ℹ️ **Note:** Additional datasets are available. See the README.md file in the
[umd-fcrepo-sample-data](https://bitbucket.org/umd-lib/umd-fcrepo-sample-data)
repository for more information.

7.8) Exit from the "plastron" container and switch back to the base directory:

```bash
plastron> exit
> cd ..
```

## Step 8: Setup and run Archelon

8.1) Switch to the Archelon directory:

```bash
> cd archelon
```

8.2) Copy the "docker-archelon-template.env" to "docker-archelon.env"

```bash
> cp docker-archelon-template.env docker-archelon.env
```

8.3) Edit the "docker-archelon.env" file:

```bash
> vi docker-archelon.env
```

and update the following parameters:

* ​FCREPO_AUTH_TOKEN - ​Replace with the "archelon" auth token generated by fcrepo
* LDAP_BIND_PASSWORD - Replace with the "FCRepo Directory LDAP AuthDN" password from the "Identities" document
* PLASTRON_PUBLIC_KEY - The contents of the "archelon_id.pub" file from Step 6.4

8.4) Build the Archelon Docker image:

```bash
> docker build -t docker.lib.umd.edu/archelon:latest -f Dockerfile .
```

8.5) Deploy the "archelon" Docker stack:

```bash
> docker stack deploy -c docker-compose.yml archelon
```

8.6) Verify that Archelon is running by going to <http://localhost:3000/>

After logging in, the Archelon home page should be displayed, and the
"Collection" panel should display a "Student Newspapers" entry.

ℹ️ **Note:** If you get a "Not Authorized" page when going to
<http://localhost:3000/>, your browser is likely caching a credential from
a previous Archelon login. Go to <http://localhost:3000/> in a *private*
browser window (which should show the CAS login page). Once you log in,
refresh the "Not Authorized" page -- it should now permit entry.

---
[fcrepo-repository-structure]: https://confluence.umd.edu/display/LIB/Fedora%3A+Repository+Structure
