class Figure < Hash

  module Store

    def []=(k, v)
      self.class.send :define_method, k, -> { custom_fetch k } unless respond_to? k
      super
    end

    def default(k=nil)
      if k && !default_store.has_key?(k) && can_forward?
        self[:default]

      elsif default_store && k
        default_store[k]

      elsif has_key? :default
        self[:default]
      end
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

    def has_key?(key)
      [key.to_s, key.to_sym].detect { |k| super(k) }
    end

    private

    def default_store
      @default_store ||= self.class.ancestors[1].instance rescue nil
    end

    def custom_fetch(k)
      if self[k].respond_to?(:can_forward?) && self[k].can_forward?
        self[k].forward!

      else
        self[k]
      end
    end

  end

end
