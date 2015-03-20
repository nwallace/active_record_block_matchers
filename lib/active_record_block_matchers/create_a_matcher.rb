RSpec::Matchers.define :create_a_new do |klass|
  supports_block_expectations

  description do
    "create a #{klass}, optionally verifying attributes"
  end

  chain(:with_attributes) do |attributes|
    @attributes = attributes
  end

  chain(:which) do |&block|
    @which_block = block
  end

  match do |block|
    time_before = Time.current

    block.call

    column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
    @created_records = klass.where("#{column_name} > ?", time_before)
    return false unless @created_records.count == 1

    record = @created_records.first

    @attribute_mismatches = []

    @attributes && @attributes.each do |field, value|
      unless record.public_send(field) == value
        @attribute_mismatches << [field, value, record.public_send(field)]
      end
    end

    if @attribute_mismatches.none? && @which_block
      begin
        @which_block.call(record)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        @which_failure = e
      end
    end

    @attribute_mismatches.empty? && @which_failure.nil?
  end

  failure_message do
    if @created_records.count != 1
      "the block should have created 1 #{klass}, but created #{@created_records.count}"
    elsif @attribute_mismatches.any?
      @attribute_mismatches.map do |field, expected, actual|
        "Expected #{field} to be: #{expected}, but was: #{actual}"
      end.join("\n")
    else
      @which_failure.message
    end
  end

  failure_message_when_negated do
    if @created_records.count == 1
      "the block should not have created a #{klass}, but created #{@created_records.count}"
    else
      "the block created a #{klass} that matched all given criteria"
    end
  end
end

RSpec::Matchers.alias_matcher :create_a,  :create_a_new
RSpec::Matchers.alias_matcher :create_an, :create_a_new
