require 'singleton'
require 'yaml'

class Figure < Hash

  include Singleton

  include DepartmentStore
  include Store

  class << self

    attr_reader :config_directory

    def configure
      yield self
    end

    def config_directory=(path)
      @config_directory = Pathname.new path
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

  def initialize
    @config_directory = self.class.config_directory
    @figure_out = {}
    store!
  end

  def store!
    Dir[
      config_directory.join('**/*figure.yml'),
      config_directory.join('**/figure/*.yml'),
      config_directory.join('**/gaston/*.yml')
    ].map { |file|Pathname.new file }.each do |conf|
      name = conf.basename.to_s.sub('.yml', '').sub('.figure', '')
      data = YAML.load conf.read

      instance_variable_set "@#{name}", new_store(name, data)

      define_singleton_method name.to_sym do
        figure_out instance_variable_get("@#{name}")
      end

  def []=(k, v)
    super.tap do |value|
      self.class.define_singleton_method k.to_sym do
        instance.send k
      end
    end
  end

  private

  def figure_out(store)
    @figure_out[store] ||= store.respond_to?(env.to_s) ? store.send(env) : store
  end

  def env
    defined?(Rails) ? Rails.env : nil
  end

  def config_directory
    @config_directory ||= defined?(Rails) ? Rails.root.join('config') : ascend_path
  end

  def ascend_path
    Pathname.new(__FILE__).ascend do |path|
      @config_directory ||= path.join('config') if path.join('config').exist?
      @config_directory ||= path if path.join('figure.yml').exist?
    end
  end

end
