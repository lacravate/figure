class Figure < Hash

  module DepartmentStore

    private

    def new_store(k, v={}, parent_klass=Figure::Figurine)
      store_klass(parent_klass, k.to_s.capitalize).new v
    end

    def store_klass(parent_klass, name)
      Class.new(default_klass(parent_klass, name)).tap do |klass|
        parent_klass.const_set name, klass
        Figure.stores[klass.pattern] = klass if klass.default_type
      end
    end

    def default_klass(parent_klass, name)
      default_match = Figure.stores.keys.select do |k|
        "#{parent_klass}::#{name}" =~ /^#{k}$/
      end.reverse.first

      Figure.stores[default_match] || parent_klass
    end

  end

end
