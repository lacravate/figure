class Figure < Hash

  class Figurine < Hash

    include DepartmentStore
    include Store

    def self.default_type
      @default_type ||= name.include? 'Default'
    end

    def self.pattern
      @pattern ||= name.gsub 'Default', '[^:]+'
    end

    def initialize
      (h.delete(:default) || h.delete(:gaston)).tap do |default_data|
        self[:default] = new_store :default, default_data, self.class if default_data
      end

      merge! h
    end

  end

end
