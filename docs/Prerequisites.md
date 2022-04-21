# Installing Prerequisites

Archelon requires the following:

* Ruby 2.6.3
* Bundler
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
rbenv install 2.6.3
```

## Bundler

Make sure you are using the Ruby 2.6.3 environment, then install the gem as usual:

```
rbenv shell 2.6.3
gem install bundler
```

## Yarn

On OS X with Homebrew, Yarn can be installed with: `brew install yarn`.

## /etc/hosts

Edit this "/etc/hosts" file:

```
sudo vi /etc/hosts
```

and add an "fcrepo-local" alias to the "127.0.0.1" entry:

```
127.0.0.1       localhost fcrepo-local
```

---

[Back to Archelon setup](../README.md#setup)

[rbenv]: https://github.com/rbenv/rbenv