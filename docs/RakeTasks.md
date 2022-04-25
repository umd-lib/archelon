# Archelon Rake Tasks

* [docker:tags, docker:build, docker:push](#dockertags-dockerbuild-dockerpush) - Build and Push Docker Images
* [jobs:work](#jobswork) - Run the DelayedJobs Workers
* [user:add_public_key](#useradd_public_key) - Add User Public Key
* [user:add_public_key_file](#useradd_public_key_file) - Add User Public Key File
* [plantuml:images](#plantumlimages) - Generate Documentation Images
* [stomp:listen](#stomplisten) - Run the STOMP Listener
* [vocab:import](#vocabimport) - Importing Controlled Vocabularies

## docker:tags, docker:build, docker:push

There arethree Rake tasks to list, build, and push Docker images for the Archelon
application as well as the SFTP service. The image tag version is determined
by the value of `Archelon::VERSION`. If it contains the string "dev", then
it is considered a development version as is tagged using "latest". Any other
value is used as-is.

Note that once a non-"latest" tag has been successfully pushed, further attempts
to push that same tag will fail.

```bash
# lists the tags that would be built or pushed
rails docker:tags

# builds "docker.lib.umd.edu/archelon:VERSION" and "docker.lib.umd.edu/archelon-sftp:VERSION"
rails docker:build

# push to the registry
rails docker:push
```

Implemented using **Boathook::DockerTasks** from the [boathook](https://github.com/umd-lib/boathook) gem; source: [docker.rake](../lib/tasks/docker.rake)

## jobs:work

To enable job execution, start the delayed_job workers:

```bash
rails jobs:work
```

## plantuml:images

Generate SVG images from the PlantUML source documentation in the [docs](../docs)
directory. The output files are placed in [docs/img](../docs/img)

Requires the `PLANTUML_JAR` environment variable to be set, giving the full path
to the `plantuml.jar` file to run. It is recommended to add this value to a
`.env` or `.env.local` file on your development workstation.

```bash
rails plantuml:images
```

Source: [plantuml.rake](../lib/tasks/plantuml.rake)

## stomp:listen

The STOMP Listener application connects Archelon to ActiveMQ, and is required
for performing exports and imports. The STOMP listener application is configured
via the environment variables in the ".env" file, and run using the following
Rake task:

```bash
rails stomp:listen
```

Source: [stomp.rake](../lib/tasks/stomp.rake)

## user:add_public_key

Adds the given public key for the user with the given CAS directory id:

```bash
rails user:add_public_key[cas_directory_id,public_key]
```

A user with the given CAS directory id must already exist.

Note: Because of the way SSH public keys are expressed, the command
should be enclosed in quotes, i.e.:

```bash
rails "user:add_public_key[jsmith,ssh-rsa AAAAB3NzaC1yc2E...]"
```

Source: [add_public_key.rake](../lib/tasks/add_public_key.rake)

## user:add_public_key_file

Adds the public key from the given file for the user with the given CAS
directory id:

```bash
rails user:add_public_key_file[cas_directory_id,public_key_file]
```

A user with the given CAS directory id must already exist.

Relative file paths are allowed. If the file path or file name contains
a space, the entire command should be enclosed in quotes.

Example:

```bash
rails user:add_public_key_file[jsmith,/home/jsmith/.ssh/id_rsa.pub]
```

Source: [add_public_key.rake](../lib/tasks/add_public_key.rake)

## vocab:import

Load of vocabulary terms from a CSV file:

```bash
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

Source: [vocab.rake](../lib/tasks/vocab.rake)
