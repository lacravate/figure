# Figure

A classic configuration store, that turns out Hash definitions to methods, with
a (so far very unsatisfactory, yet functionnal) management of environment
(and Rails environment).

## Installation

Ruby 1.9.2 is required (i guess... 2.* for sure).

Install it with rubygems:

    gem install figure

With bundler, add it to your `Gemfile`:

```ruby
gem "figure"
```

## Use

### Configuration of the configuration

The usual...

```ruby
Figure.configure do |config|
  config.config_directory = "yours"
  config.env = "your_env"
end
```

Otherwise, would find Rails `config` directory, and set `Rails.env` as the
environment parameter to deal with on its own, like a big boy.

### Files

YAML. So far.

Will look at any such file, in the above-mentioned `config_directory`, that is
to be named `*.figure.yml` or to be found in a `figure` subdirectory

Have a peep at the fixture files in the spec directory to see what kind of YAML
will be made useful.

## Thanks

Eager and sincere thanks to all the Ruby guys and chicks for making all this so
easy to devise.

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
