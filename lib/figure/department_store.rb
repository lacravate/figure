class Figure < Hash

  module DepartmentStore

    private

    def new_store(k, v={}, parent_klass=Figure::Figurine)
      @default_type = k == :default
      store_klass(parent_klass, k.to_s.capitalize).new v
    end

    def store_klass(parent_klass, name)
      Class.new(default_klass(parent_klass, name)) do |klass|
        parent_klass.const_set name, klass
      end
    end

    def default_klass(parent_klass, name)
      figure, store, namespace, *depths = parent_klass.name.split('::')

      default = if namespace && !@default_type
        (depths << name)[0] = "Default"

        [figure, store, namespace, *depths].inject(Object) do |constant, child|
          constant.const_get child if constant && constant.const_defined?(child)
        end
      end

      default || parent_klass
    end

  end

end
