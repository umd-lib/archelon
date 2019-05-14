# Rails Update Notes

## Introduction

As Rails evolves, various configuration options are added to preserve
existing functionality. 

This page is intended to record information about this application
that may prove useful when performing updates in the future. This
page _should_ be updated to remove information when it is no longer
relevant.

## config/initializers/to_time_preserves_timezone.rb

The "config/initializers/to_time_preserves_timezone.rb" file sets the 
"ActiveSupport.to_time_preserves_timezone" flag to "false", to preserve
backward compatibility, even if Ruby is upgraded to v2.4, which changes
the way "to_time" behaves.

In Rails 5, this parameter moves to config/initializers/new_framework_defaults.rb
so this file can be deleted. The parameter should remain "false" until it
is determined the application if dependent on the "to_time" behavior as
it exists in Ruby 2.2.4.

**References:**

* https://github.com/rails/rails/blob/v4.2.8/activesupport/CHANGELOG.md
