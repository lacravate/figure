RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
  config.order = :random

  # config.warnings = true
  # config.default_formatter = 'doc' if config.files_to_run.one?

  Kernel.srand config.seed
end

require_relative '../lib/figure'

Figure.configure do |config|
  config.config_directories << File.join(File.dirname(__FILE__), 'fixtures')
  config.config_directories << File.join(File.dirname(__FILE__), 'other_fixtures')
end

Figure::GastonInitializer.initialize!
