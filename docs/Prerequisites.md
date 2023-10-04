# Installing Prerequisites

Archelon requires the following:

* Ruby 2.7.6
* Bundler 1.17.2
* [Yarn](https://yarnpkg.com/)

## Ruby

The recommended way to install the required version of Ruby is to use
the [rbenv] version manager.

On OS X with Homebrew, run the following:

```
brew install rbenv
rbenv init
```

Follow the printed instructions to set up rbenv shell integration. Then, in a
new terminal:

```
rbenv install 2.7.6
```

## Bundler

Make sure you are using the correct Ruby environment, then install the gem as
usual:

```
rbenv shell 2.7.6
gem install bundler:1.17.2
```

**Note:** Archelon's Gemfile is currently created with an older version of
Bundler, so requires a specific version to be installed.

## Yarn

On OS X with Homebrew, Yarn can be installed with: `brew install yarn`.

## /etc/hosts

Edit your "/etc/hosts" file:

```
sudo vi /etc/hosts
```

and add "fcrepo-local" and "archelon-local" aliases to the "127.0.0.1" entry:

```
127.0.0.1       localhost fcrepo-local arcehlon-local
```

---

[Back to Archelon setup](../README.md#setup)

[rbenv]: https://github.com/rbenv/rbenv