$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record_block_matchers"
require "sqlite3"
require "database_cleaner"
require "pry"

db_config = YAML::load(File.open("db/config.yml")).fetch("test")
ActiveRecord::Base.establish_connection(db_config)

# Load spec support files
Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.include ActiveRecordBlockMatchers::SpecUtilities
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
