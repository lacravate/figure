require 'singleton'

class Figure < Hash

  class Figurine < Hash

    include Singleton

    include DepartmentStore
    include Store

    class << self

      attr_accessor :with_data

      def default_type
        @default_type ||= name.include? 'Default'
      end

      def pattern
        @pattern ||= name.gsub 'Default', '[^:]+'
      end

      def with(data)
        self.tap { |s| s.with_data = data }
      end

    end

    def initialize
      h = self.class.with_data || {}

      (h.delete(:default) || h.delete(:gaston)).tap do |default_data|
        self[:default] = new_store :default, default_data, self.class if default_data
      end

      merge! h
    end

  end

end
