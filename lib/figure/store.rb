class Figure

  class Store < Hash

    include DepartmentStore

    def initialize(h={})
      (h[:default] || h[:gaston]).tap do |default|
        h.delete :default
        h.delete :gaston
        self[:default] = default_store(default) if default
      end

      merge! h
    end

    def []=(k, v)
      unless respond_to? k
        that = self
        self.class.send :define_method, k, Proc.new { @current_default = that; self[k] }
      end

      super
    end

    def default(k=nil)
      k ? @current_default[k] : self[:default]
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
      new_store :default, data, self.class
    end

  end

end
