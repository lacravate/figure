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

end
