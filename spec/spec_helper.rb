$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record_block_matchers"
require "sqlite3"
require "pry"

db_config = YAML::load(File.open("db/config.yml")).fetch("test")
ActiveRecord::Base.establish_connection(db_config)

class Person < ActiveRecord::Base
  # attributes :first_name, :last_name, :created_at, :updated_at
  def full_name
    "#{first_name} #{last_name}"
  end
end

RSpec.configure do |config|
  config.after(:each) do
    Person.delete_all
  end
end
