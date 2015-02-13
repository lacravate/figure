# Figure

A classic configuration store, that turns out Hash keys to methods to render an
environment-aware configuration. Likewise, it handles any other application-wide
value that can modify the rendering of the configuration.

## Installation

Ruby 1.9.3 is required (i guess... 2.* for sure).

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
require 'figure'

Figure.configure do |config|
  config.config_directories << "yours"
  config.env = "your_env"
end

if Figure.that.configuration.item
  # value would be found in that.figure.yml
  # see `Sources` below for other options on source file names and location
  puts "our configuration has this item : #{Figure.that.configuration.item}"
end
```

### Sources

YAML files. So far.

In the above-mentioned `config_directories, will look for any such file, that is
named `*.figure.yml` or found in a `figure` subdirectory

Have a peep at the fixture files in the `spec/` directory to see what kind of
YAML will be made useful.

## Modifyer values

### Environment - `default_env` key

In a `conf.figure.yml` file :

```
:my_conf:
  :hash:
    :default_env:
      :answer: 42
    :test:
      :answer: 0
    :production:
      :answer: 41
```

Will spot `default_env` key, will understand it defines defaults (yah a-will),
and will look into a list of classes/modules for one that responds to `env`. The
returned value will be used to render the fitting configuration according to it.

Hence in ruby code :

```ruby
Figure.configure do |c|
  c.env = 'test'
end

# - hash keys are namespaced by the file name `conf`
# - :test node is omitted
puts Figure.conf.my_conf.hash.answer # puts 0
```

See `Responders` below for the said "responders" list.

### `default_anything` key

The same key pattern can be used to set any other modifyer value.

With a 'services.figure.yml' file :

```
:available:
  :default_locale:
    :fr:
      - foo
      - bar
      - baz
      - bam
    :en:
      - foo
      - bar
      - tender

```

The french instance of the applications will offer the `foo, bar, baz, bam`
services while the english one `foo, bar, tender`, found in ruby code with a :

```ruby
Figure.services.available
```

See `Responders` below for the manner to have Figure use the correct locale
value, and thus the correct locale node.

## Responders

To get the current value of `anything` when a `default_anything` key is spotted,
Figure class will be probed. But so far, only the `env` accessor is defined
for this class.

So if a custom `responder` is needed, it can be pushed in the `Figure.responders`
array.

In the above example, with `default_locale` node :

```rubygems
# given the i18n gem is available
I18n.locale = :en
Figure.responders << I18n

puts Figure.services.available # => [:foo, :bar, :tender]

```

## Rails

When Rails is defined, `figure` will push the `Rails.root.join('config')`
subdirectory in the `config_directories`, to point the conf' files location.

`Rails` will be pushed as well in the `Figure.responders`. Hence, `Rails.env`
will be available to `figure` to render the proper configuration.

## Thanks

Eager and sincere thanks to all the Ruby guys and chicks for making all this so
easy to devise.

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
