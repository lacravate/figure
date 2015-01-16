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

      def with(options)
        tap do |f|
          options.each do |k, v|
            f.send "with_#{k}=", v
          end
        end
      end

    end

    attr_accessor :forwarders

    def initialize
      @forwarders = [self, self.class, Figure]

      h = self.class.with_data || {}
      default_h, @forward = find_default h

      self[:default] = new_store :default, default_h, self.class if default_h
      merge! h
    end

    def forward!
      self[ forward_response ]
    end

    def can_forward?
      !!@forward
    end

    private

    def find_default(h)
      key = h.keys.detect { |k| k.to_s =~ /^(default|gaston)(_.+)?$/ }

      [h.delete(key), $2 && $2[1..-1]]
    end

    def forward_response
      responder.send @forward if responder
    end

    def responder
      @responder ||= forwarders.detect { |s| s.respond_to? @forward }
    end

  end
end
