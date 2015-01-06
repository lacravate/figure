# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'figure/version'

Gem::Specification.new do |s|
  s.name          = "figure"
  s.version       = Figure::VERSION
  s.authors       = ["lacravate"]
  s.email         = ["david.elbaz@af83.com"]
  s.homepage      = "https://github.com/lacravate/figure"
  s.summary       = "Figure...'s out configuration from YAML files"
  s.description   = "A classic configuration store, that turns out Hash definitions to methods, with a (so far very unsatisfactory) management of environment (and Rails environment)"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
  s.add_development_dependency 'rspec'
end
