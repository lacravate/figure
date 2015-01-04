require 'singleton'

class Figure < Hash

  class Figurine < Hash

    include Singleton

    include DepartmentStore
    include Store

    class << self

      attr_accessor :with_data, :label

      def default_type
        @default_type ||= label.include? 'Default'
      end

      def pattern
        @pattern ||= label.gsub 'Default', '[^:]+'
      end

      def with(data)
        self.tap { |s| s.with_data = data }
      end

    end

    def initialize
      h = self.class.with_data || {}

      (h.delete(:default) || h.delete(:gaston)).tap do |data|
        self[:default] = new_store :default, data, self.class if data
      end

      merge! h
    end

  end

end
