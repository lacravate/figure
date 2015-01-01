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

    def initialize(h={})
      (h.delete(:default) || h.delete(:gaston)).tap do |default|
        self[:default] = default_store default if default
      end

      merge! h
    end

  end

end
