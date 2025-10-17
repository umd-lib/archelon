# Archelon Rake Tasks

* [jobs:work](#jobswork) - Run the DelayedJobs Workers
* [plantuml:images](#plantumlimages) - Generate Documentation Images
* [stomp:listen](#stomplisten) - Run the STOMP Listener
* [user:add_public_key](#useradd_public_key) - Add User Public Key
* [user:add_public_key_file](#useradd_public_key_file) - Add User Public Key File

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

A PlantUML jar file can be downloaded from <https://plantuml.com/download>.

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
