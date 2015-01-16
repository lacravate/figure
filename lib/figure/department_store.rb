class Figure < Hash

  module DepartmentStore

    private

    def new_store(k, v={}, parent_klass=Figure::Figurine)
      store_klass(parent_klass, k.to_s.capitalize).with(data: v).instance
    end

    def store_klass(parent_klass, name)
      label = parent_klass.label.to_s + '::' + name

      Class.new( default_klass(label) || parent_klass ).tap do |klass|
        klass.label = label
        Figure.stores[klass.pattern] = klass if klass.default_type
      end
    end

    def default_klass(label)
      Figure.stores[
        Figure.stores.keys.reverse.detect { |k| label =~ /^#{k}$/ }
      ]
    end

  end

end
