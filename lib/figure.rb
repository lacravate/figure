require 'figure/store'
require 'figure/department_store'
require 'figure/figure'
require 'figure/figurine'

class Gaston < Figure
  class << self
    def method_missing(*args, m)
      link unless @instantiated
      super
    end

    def link
      Figure.instance.keys.each do |root|
        Figure.send(root).figures.each do |k|
          instance[k] = Figure.send(root)[k]
        end
      end
    end
  end
end

if defined?(Rails)
  Figure.configure do |fig|
    fig.env = Rails.env
  end
end
