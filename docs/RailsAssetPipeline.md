# Rails Asset Pipeline

## Introduction

This document attempts to provide background and useful information to
developers about the Rails asset pipeline in use by Archelon.

## Background

The Rails-recommended default for the asset pipeline has changed significantly
from Rails 5.

Unfortunately, the Rails 7.1-recommended default for the asset pipeline, the
"importmaps-rails" gem, does not support React. See
[docs/decisions/0004-rails-7.1-asset-pipeline.md](decisions/0004-rails-7.1-asset-pipeline.md)
for a larger discussion of the choice of the "esbuild" JavaScript build tool.

To understand the Rails asset pipeline, it is helpful to look at each of the
pieces. The following quotes are from the book “Modern Front-End Development
for Rails, 2nd Edition” by Noel Rappin (ISBN : 1-68050-998-5).

### Yarn

**Note:** The VS Code Dev container for Archelon uses Yarn v1.22.22 -
<https://classic.yarnpkg.com/en/docs>

> The problem Yarn is designed to solve is: “What version of all my dependent
> modules does my program rely on?” Yarn is for JavaScript and npm modules what
> Bundler is for Ruby gems. All the JavaScript packaging tools supported by
> jsbundling—esbuild, rollup, and webpack—use Yarn and the package.json file to
> manage dependencies.

One way to think of Yarn is that "Yarn == Bundler" for JavaScript packages.

Relevant files:

* package.json

  > The package.json file is used to manage dependencies, configure some of those
  > dependent tools, define commands for working with your code, and store
  > information about your code should you choose to publish your code as a node
  > module in its own right.

* yarn.lock

  Equivalent to “Gemfile.lock”

### esbuild

<https://esbuild.github.io/>

> With Yarn in place to manage our third-party dependencies, we can look at a
> different set of problems. Problems like “How can my code consistently
> reference other code, when that code is in another one of my code files or
> in third-party modules?” and “How can I convert all of my disparate
> front-end assets into something that can be sent to and managed by a
> browser?”

Requires that “Node” is installed.

Relevant files and directories:

* package.json

  Added to “package.json” as a dependency, then used via the “scripts” section
  of the “package.json” file.

* esbuild.config.mjs

  Used to configure the JavaScript build process (mostly by convention).

* app/javascript/application.js

  Base JavaScript file esbuild uses to locate other JavaScript files to be
  included in the application

* app/javascript/components

  Holds React JSX files

### jsbundling-rails

<https://github.com/rails/jsbundling-rails>

Rails gem that takes JavaScript assets in the “app/assets/builds​” directory,
and makes it available to the application (for development), and for packaging
up the JavaScript (for production).

Relevant directory:

* app/assets/builds

### Sass

<https://sass-lang.com/>

Loaded as a JavaScript dependency and run via a script in "package.json",
converts “.scss” files into regular CSS files and places them in the
“app/assets/builds” directory.

Relevant file:

* package.json

### Propshaft

<https://github.com/rails/propshaft>

Replacement for the “sprockets” gem

> Bundling the JavaScript and CSS files together is only half of the process of
> serving assets, sometimes called the asset pipeline. You also have to send the
> asset files down to the server. This would seem to be straightforward—just put
> the files in the public directory—but there are always ways to make things a
> little more interesting in the name of performance or ease of use.
> ...
> (Sprockets) was a useful tool, but the Rails team struggled to keep Sprocket
> up to date with the larger front-end ecosystem. With the advent of the
> jsbundling and cssbundling gems, there’s no need to keep up, the integration
> point has moved, and the third-party tool is now responsible for everything
> needed to put the bundle into the assets/builds directory. This allows for an
> asset pipeline tool that has much less responsibility and is significantly
> simpler than Sprockets, which is where Propshaft comes in.
