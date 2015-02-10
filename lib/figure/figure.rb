require 'singleton'
require 'yaml'

class Figure < Hash

  include Singleton

  include DepartmentStore
  include Store

  class << self

    attr_accessor :env

    def initializers
      @initializers ||= []
    end

    def config_directories
      @config_directories ||= []
    end

    def responders
      @responders ||= []
    end

    def stores
      @stores ||= {}
    end

    def configure
      yield self
    end

    def method_missing(*args, m)
      if @instantiated
        super
      else
        @instantiated = instance
        send m
      end
    end

  end

  CONFIG_GLOBS = %w|**/*figure.yml **/figure/*.yml **/gaston/*.yml|

  def initialize
    self.class.initializers.each &:initialize!
    @config_directories = self.class.config_directories.map { |path| Pathname.new path }
    store!
  end

  def store!
    config_files do |name, conf|
      self[name.to_sym] = new_store name, YAML.load(conf.read)
    end
  end

  def []=(k, v)
    super.tap do |value|
      self.class.define_singleton_method k.to_sym do
        instance.send k
      end
    end
  end

  def config_files
    Dir[ *all_config_directories_globs ].map do |file|
      path = Pathname.new file
      name = path.basename.to_s.sub('.yml', '').sub('.figure', '')

      yield name, path if block_given?
    end
  end

  private

  def config_directories
    @config_directories ||= [ ascend_path ]
  end

  def all_config_directories_globs
    config_directories.map do |dir|
      CONFIG_GLOBS.map do |glob|
        dir.join glob
      end
    end.flatten
  end

  def ascend_path
    Pathname.new(__FILE__).ascend do |path|
      @config_directories << path.join('config') if path.join('config').exist?
      @config_directories << path if path.join('figure.yml').exist?
    end
  end

end
