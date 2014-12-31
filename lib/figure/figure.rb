class Figure

  module DepartmentStore

    private

    def new_store(k, v={}, parent_klass=Figure::Store)
      name = parent_klass.name.split('::').last == "Default" ? "Default" : k.to_s.capitalize

      store_klass(parent_klass, name).new v
    end

    def store_klass(parent_klass, name)
      Class.new(default_klass(parent_klass, name)) do |klass|
        parent_klass.const_set name, klass
      end
    end

    def default_klass(parent_klass, name)
      figure, store, namespace, *depths = parent_klass.name.split('::')
      if namespace && name != "Default"
        store = Figure::Store.const_get namespace
        depths.push('').inject(store) do |constant, child|
          constant.const_get :Default
        end
      else
        parent_klass
      end
    end

  end

  class Store < Hash

    include DepartmentStore

    def initialize(h={})
      (h[:default] || h[:gaston]).tap do |default|
        h.delete :default
        h.delete :gaston
        self[:default] = default_store(default) if default
      end

  class << self

    attr_reader :config_directory

    def configure
      yield self
    end

    def config_directory=(path)
      @config_directory = Pathname.new path
    end

    def merge!(h)
      h.each do |k, v|
        self[k] = if v.is_a? Hash
          new_store k, v, self.class
        elsif v.is_a? Array
          v.map do |i|
            i.is_a?(Hash) ? new_store(k, i, self.class) : i
          end
        else
          v
        end
      end
    end

    def default_store(data)
      new_store(:default, data, self.class)
    end

  end

  include Singleton

  include DepartmentStore

  attr_reader :config

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
