RSpec::Matchers.define :create_records do |klasses|
  include ActiveSupport::Inflector

  supports_block_expectations

  description do
    "create #{klasses}"
  end

  match do |block|
    time_before = Time.current

    block.call

    @created_records = {}
    klasses.each do |klass, count|
      column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
      @created_records[klass] = klass.where("#{column_name} > ?", time_before)
    end.select do |klass, count|
      count != @created_records[klass].count
    end.empty?
  end

  failure_message do
    generate_failure_message(klasses, "should")
  end

  failure_message_when_negated do
    generate_failure_message(klasses, "should not")
  end

  def generate_failure_message(klasses, should)
    klasses.select do |klass, count|
      @created_records[klass] != count
    end.map do |klass, count|
      "The block #{should} have created #{count} #{klass.name.pluralize(count)}, but created #{@created_records[klass].count}."
    end.join(" ")
  end
end

RSpec::Matchers.alias_matcher :create, :create_records
