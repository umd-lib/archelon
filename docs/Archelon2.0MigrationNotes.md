# Archelon 2.0 Migration Notes

## Introduction

This document attempts to capture information useful to developers when moving
functionality to Archelon 2.0.

## Application Configuration

Archelon 2.0 is based on the following dependencies:

* Ruby 3.2
* Rails 7.1
* Blacklight 8.3
* Bootstrap 5

The Rails application was originally created with the following command:

```zsh
$ rails new . \
    --asset-pipeline=propshaft \
    --javascript=esbuild \
    --css=bootstrap \
    --skip-hotwire \
    --skip-jbuilder \
    --name=archelon
```

resulting in a Rails application using:

* Sass/bootstrap for CSS
* Using Rails 7 preferred “propshaft” gem for handling assets
* Excluding Hotwire (because we will probably use HTMX instead)
* Excluding JBuilder, because it is just extra cruft
* "jsbundling-rails", "cssbundling-rails", and the "esbuild" tool
  for the asset pipeline. See [RailsAssetPipeline.md](RailsAssetPipeline.md) for
  more information.

The Rails "Turbo" functionality has also been disabled.

## Running the Application in Local Development

Rails 7 has changed the way that the application is run in the local development
environment. Instead of using `rails server`, run:

```zsh
$ bin/dev
```

This executes a script that uses the `foreman` gem and the `Procfile.dev`
configuration file to automatically build (and hot-rebuild) the JavaScript and
CSS files, and start the application (see
<https://railsnotes.xyz/blog/procfile-bin-dev-rails7> for a
short introduction of what's going on "under the hood").

## Notable Changes

This section details changes to legacy Archelon during the migration that are
likely to affect ongoing development.

### View Components

Blacklight started moving some parts of the Web interface to “view components”
starting in Blacklight v7.8.0.

See <https://viewcomponent.org/> for more information.

Blacklight 8 is configured to the latest “view_component” version (actual
version used by Archelon is v3.12.1).

### Some Blacklight functionality may require Rails “Turbo”

Some Blacklight functionality may require the Rails "Turbo" functionality to
be enabled. See <https://github.com/projectblacklight/blacklight/issues/2721>
for some discussion.

As UMD has had problems with Rails "turbolinks" interfering with JavaScript in
the past, the Rails 7.1 application was created without "Turbo" functionality.

Turbo functionality may need to be re-enabled, if we find Blacklight
functionality that truly relies on it.

### SQLite now honors foreign key constraints

As of Rails 6, SQLite now honors foreign key constraints, which causes tests in
the following files to fail:

* test/controllers/cas_users_controller_test.rb
* test/jobs/delete_old_exports_job_test.rb

### JavaScript assets moved to app/javascript

In Rails 6, JavaScript assets moved from "app/assets/javascripts" to
"app/javascript".

### esbuild and JavaScript

The "esbuild" tool does not automatically pick up JavaScript files in the
"app/javascript" directory. Instead, it uses "app/javascript/application.js"
as the "entry point" file, incorporating all the files that it imports (and,
transitively, all the files they import). This means that when adding a
JavaScript file, it may be necessary to add an "import" statement in the
"app/javascript/application.js" for the added file to be "reachable"
for the build tool.

To check whether "esbuild" can reach the file, examine the compiled JavaScript
in the "app/assets/builds" directory.

### Blacklight::SearchHelper replaced by Blacklight::Searchable

The “Blacklight::SearchHelper”
(app/controllers/concerns/blacklight/search_helper.rb) from Blacklight 6 has
been replaced (with some slightly different semantics) by
“Blacklight::Searchable” (app/controllers/concerns/blacklight/searchable.rb) in
Blacklight 8.

In particular, the “fetch” method has been moved to the “SearchService” class
(app/services/blacklight/search_service.rb), so uses of the method must now use
`search_service.fetch`.

Also, the return value has changed from a two-item array
`[Blacklight::Solr::Response, Blacklight::SolrDocument]` to a single
SolrDocument (or array of SolrDocuments, if an array of ids is given).

### “link_to” helper changes

The “link_to” helper in ERB templates has changed in Rails 7 (se
<https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to>).
In particular the typically style used in Archelon, i.e., like the following
from “app/views/shared/_user_util_links.html.erb“:

```erb
<%= link_to 'Download URLs', controller: 'download_urls', action: 'index' %>
```

is no longer supported, and referred to as the “older argument” style. When
using the “older argument” style, a literal hash is required around the
“controller” argument, if you want to add an HTML “class” attribute, i.e.:

> Be careful when using the older argument style, as an extra literal hash is
> needed:

```erb
<%= link_to 'Download URLs', { controller: 'download_urls' }, action: 'index', class: 'nav-link' %>
```

### Form “data-remote: true”/”local:false”

* <https://stackoverflow.com/a/75410391>
* <https://stackoverflow.com/a/45305004>
* <https://github.com/rails/rails/issues/49499>

For forms expecting an AJAX response, add `local: false`, to the ERB tag. This
causes the `data-remote:true` attribute to be added to the form. For example in
“app/views/resource/edit.html.erb”, the legacy Archelon code:

```erb
<%= form_with(id: 'resource_edit_form') do %>
```

needed to be changed to

```erb
<%= form_with(id: 'resource_edit_form', local: false) do %>
```

### Class Names and "zeitwerk" autoloader

<https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html>

Rails 7 now uses the “zeitwerk” autoloader, which has stricter rules about
converting Ruby filenames to class names. In particular, it wants to always
camel-case the name.

One instance demonstrating this was the “SendJSONRequest” class
(see "app/services/send_json_request.rb"), which had a class name of
“SendJSONRequest”, but which “zeitwerk” expected to be “SendJsonRequest”.

While it is possible to add a "inflection" configuration to
“config/initializers/zeitwerk.rb” to correct this, opted instead for this
migration to simply rename the affected class.

Also affected were the following files, which used “HTTP” as a module name
(changed to “Http”):

* app/services/plastron_services/http/publication_command.rb
* app/services/plastron_services/http/publish_hidden_item.rb
* app/services/plastron_services/http/publish_item.rb
* app/services/plastron_services/http/send_activity_stream_message.rb

### Route customizations to support fcrepo URL in “id” parameter

The Blacklight routes do not expect to have a “.” (period) in the “id” parameter
passed to routes. When running in Kubernetes, Archelon references the URL of
the fcrepo server in the “id” parameter , which contains periods. Without
changes, this leads to errors such as the following when accessing an item
detail page:

```text
ActionController::RoutingError (No route matches [POST] "/catalog/https:%2F%2Ffcrepo.sandbox.lib.umd.edu%2Ffcrepo%2Frest%2Fdc%2F2021%2F2%2Fd6%2Fdb%2F20%2Fbe%2Fd6db20be-dece-491a-a11d-93bf8b4e1379/track"):
```

Note that this issue also occurs in legacy Archelon, and was fixed by adding
constraints: `{ id: /.*/ }` to the various routes that use an “id” parameter
(see <https://github.com/umd-lib/archelon/commit/cfd6126498e5d8aa1e427622ae4e1a846f5b685d>).

In this migration, copied the stock Blacklight 8.3.0
“lib/blacklight/routes/searchable.rb” file and modified it to add the
`constraints: { id: /.*/ }` parameter. This was done instead of adding the
change to the “app/helpers/url_helper.rb” file in the above legacy Archelo
commit. Also added the `constraints: { id: /.*/ }` parameter to the
“config/routes.rb” file.

### sprockets vs propshaft in SCSS files

Replaced references to `image_url` and `font_url` in SCSS files with `url`.
See <https://stackoverflow.com/a/76429854> and
<https://github.com/rails/propshaft/blob/main/UPGRADING.md#3-migrate-from-sprockets-to-propshaft>

### "archelon" Docker container uses "rails" User

The stock Rails 7 “Dockerfile” used to create the "archelon" Docker image
creates a “rails” user for running the application (instead of the
“root” user used by legacy Archelon). There did not seem to be a need to
change the user back to “root”, and using a non-root “rails” user seems
better in any case.

One UMD customization is to set the "rails" user to have a UID/GID of "2200",
to match the UID/GID of the “plastron” user in "Dockerfile.sftp", to ensure
that it could write to the “/var/opt/archelon” directory (and its
subdirectories, which includes the “import” directory).

## Migration Oddities

The following are additional oddities/paper cuts were encountered while
migrating the legacy Archelon code.

### app/helpers/application_helper.rb - from_subquery

Had to change the “from_subquery” method in “app/helpers/application_helper.rb”
from:

```ruby
  def from_subquery(subquery_field, args)
    args[:document][args[:field]] = args[:document][subquery_field]['docs']
  end
```

to

```ruby
  def from_subquery(subquery_field, args)
    # See https://github.com/projectblacklight/blacklight/commit/dcfc74aebd4446aac85b2c2f7d10cd2c6ff8fef3
    # Can no longer assign to args[:document], so just return the value
    args[:document][subquery_field]['docs']
  end
```

because the ability to assign to the SolrDocument has been deprecated. This
means that `args[:document][args[:field]]` is no longer being changed as part
of the method.

### sqlite database for “development” and “test” is now in “storage/” directory

The database for tests is now in “storage/” instead of “db/”.

### foreman and dotenv

Rails 7.1 uses the “foreman” gem to run the asset pipeline watchers and the
Rails server, via the “bin/dev” script. As described in
<https://github.com/ddollar/foreman/issues/702>, “foreman” and the “dotenv” gem
conflict when reading in the environment variables (any environment variables
in the CLI environment are ignored, instead of overriding the variables in the
various “.env” files).

Used the workaround of adding --env=/dev/null to the “foreman” command in the
“bin/dev” script so that the CLI environment variables and “.env” files will
work as expected (i.e., that the CLI environment variables take precedence over
the “.env” files).

Added the "dotenv" gem to the "Gemfile" (the "dotenv-rails" gem is no longer
needed -- we can use "dotenv" directly).

### Use "config/secrets.yml" instead of "master.key"

Replaced Rails default "master.key" and "config/credentials.yml.enc" with the
"config/secrets.yml" file from legacy Archelon.

The use of the "config/secrets.yml" file, with the production secret key
provided by environment variables, has historically been more amenable to use
with Kubernetes, so simply continuing that practice in this version.

### Need to include “net-http” gem

In Ruby 3.0, the “Net::HTTP” class was moved to the “net-http” default gem
(see <https://rubyreferences.github.io/rubychanges/3.0.html#libraries-promoted-to-default-gems>).

Since Archelon uses the “Net::HTTP” class directly (such as in
“app/controllers/static_pages_controller.rb”), that means the “net-http” gem
needs to be added to the “Gemfile”. Otherwise, the following error occurs when
accessing the <http://archelon-local:3000/about> page:

```text
uninitialized constant Net::HTTP
```

### Pin “sass” to 1.77.7

Needed to pin the “sass” package in “package.json” to v1.77.6, because in
v1.77.7 a large number of deprecation warnings coming from Bootstrap were
being printed to the console:

```text
3:11:14 css.1  | DEPRECATION WARNING: Sass's behavior for declarations that appear after nested
13:11:14 css.1  | rules will be changing to match the behavior specified by CSS in an upcoming
13:11:14 css.1  | version. To keep the existing behavior, move the declaration above the nested
13:11:14 css.1  | rule. To opt into the new behavior, wrap the declaration in `& {}`.
13:11:14 css.1  |
13:11:14 css.1  | More info: https://sass-lang.com/d/mixed-decls
13:11:14 css.1  |
13:11:14 css.1  |     ┌──> node_modules/bootstrap/scss/_reboot.scss
13:11:14 css.1  | 503 │     font-weight: $legend-font-weight;
...
```

See also <https://github.com/sass/dart-sass/blob/main/CHANGELOG.md#1777>:

> Declarations that appear after nested rules are deprecated, because the
> semantics Sass has historically used are different from the semantics
> specified by CSS. In the future, Sass will adopt the standard CSS
> semantics.
>
> See the [Sass website](https://sass-lang.com/d/mixed-decls) for details.

Since there is no way for UMD to fix this, pinning “sass” to v1.77.6, so the
deprecations don’t clog up the console log.


### esbuild Oddity

When building the React JSX components, “esbuild” for some reason changes the
class name of “LabeledThing” to “_LabeledThing”. This causes the
“LabeledThing” React component to fail to display, with the following error in
the browser console:

```text
Uncaught Error: Cannot find component: 'LabeledThing'. Make sure your component is available to render.
```

Not entirely clear why “esbuild” is doing this, but the a fix was indicated by
<https://github.com/evanw/esbuild/issues/510>, i.e., adding “keepNames: true” to
the “esbuild.config.mjs” file.

### Internationalization Keys

The following I18n keys in the “config/locales/en.yml“ file do not appear to be
used and were removed:

```yaml
  resource_update_failed: 'Update failed'
  resource_update_no_change: 'Please make a change before submitting.'
```

### minitest “stub” issues in minitest/Ruby 3

Not sure whether this is caused by Ruby 3 or not, but had to modify the
“BinariesStats” stubs in “test/controllers/export_jobs_controller_test.rb” from:

```ruby
BinariesStats.stub(:get_stats, count: 1, total_size: too_large) do
```

to

```ruby
BinariesStats.stub(:get_stats, { count: 1, total_size: too_large }) do
```

as otherwise would get the following error:

```text
Error:
ExportJobsControllerTest#test_create_not_allowed_when_when_binaries_file_size_is_greater_than_maximum:
ArgumentError: wrong number of arguments (given 1, expected 2+)
    test/controllers/export_jobs_controller_test.rb:100:in `block in <class:ExportJobsControllerTest>'
```

### “ransack” gem now requires “ransackable_associations” and “ransackable_associations” on models

As of Ransack 4, the “ransack” gem (used for table sorting on the
“Download URLs” page, now requires explicit whitelisting of attributes and
associations (via “ransackable_attributes” and “ransackable_associations”
methods on the model). See
<https://github.com/activerecord-hackery/ransack/pull/1400>
and <https://activerecord-hackery.github.io/ransack/going-further/other-notes/#authorization-allowlistingdenylisting>.

### ActiveStorage now requires “service_name” column

ActiveStorage was updated in Rails 6.1 to add a “service_name” column to the
database, requiring additional migrations, which are added by running:

```zsh
$ rails active_storage:update
$ rails db:migrate
```

This doesn’t seem to be documented in the Rails Guides (it is apparently part of
the `rails app:update` task), but found it in Stack Overflow -
<https://stackoverflow.com/a/65961592>

Without the migration, the following error is printed:

```text
unknown attribute 'service_name' for ActiveStorage::Blob
```

The following files were added:

* db/migrate/20240730175018_add_service_name_to_active_storage_blobs.active_storage.rb
* db/migrate/20240730175019_create_active_storage_variant_records.active_storage.rb
* db/migrate/20240730175020_remove_not_null_on_active_storage_blobs_checksum.active_storage.rb

This also required adding a “service_name” parameter to the
“test/fixtures/active_storage/blobs.yml” fixture file. The “test” in the
service name parameter for that file is believed to correspond to the
“test” in “config/storage.yml”

### fixture_file_upload base directory changed

The “fixture_file_upload” base directory has apparently changed in Rails 7 from
“fixtures” to “fixtures/files”, necessitating changing the relative paths of
files.