class Figure < Hash

  module Store

    def []=(k, v)
      unless respond_to? k
        self.class.send :define_method, k, Proc.new { figure_out(k) }
      end

      super
    end

    def default(k=nil)
      default_store && k ? default_store[k] : self[:default]
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

    def default_store
      @default_store ||= self.class.ancestors[1].instance rescue nil
    end

  end

end
