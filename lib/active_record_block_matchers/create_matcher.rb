RSpec::Matchers.define :create do |klasses|
  include ActiveSupport::Inflector

  supports_block_expectations

  description do
    "create #{klasses}"
  end
  match do |block|
    time_before = Time.current

    block.call

    return_val = true
    @created_records = {}
    klasses.each do |klass, count|
      column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
      @created_records[klass] = klass.to_s.constantize.where("#{column_name} > ?", time_before)
      return_val = return_val && count == @created_records[klass].count
    end
    return_val
  end

  failure_message do
    generate_failure_message(klasses, 'should')
  end

  failure_message_when_negated do
    generate_failure_message(klasses, 'should not')
  end

  def generate_failure_message(klasses, should)
    messages = []
    klasses.each do |klass, count|
      messages << "The block #{should} have created #{count} #{klass.to_s.pluralize(count)}, but created #{@created_records[klass].count}." if @created_records[klass] != count
    end
    messages.join(' ')
  end
end