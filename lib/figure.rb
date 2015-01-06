require 'figure/store'
require 'figure/department_store'
require 'figure/figure'
require 'figure/figurine'

if defined?(Rails)
  Figure.configure do |fig|
    fig.env = Rails.env
  end
end
