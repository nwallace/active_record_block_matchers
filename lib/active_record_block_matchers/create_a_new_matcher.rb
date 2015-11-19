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

  match do |options={}, block|
    fetching_strategy = get_strategy(options.fetch(:strategy, :timestamp)).new(block)

    @created_records = fetching_strategy.new_records(klass)

    return false unless @created_records.count == 1 # ? this shouldn't be necessary for all strategies...

    record = @created_records.first

    @attribute_mismatches = []

    @attributes && @attributes.each do |field, value|
      unless values_match?(value, record.public_send(field))
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
        expected_description = is_composable_matcher?(expected) ? expected.description : expected.inspect
        "Expected #{field.inspect} to be #{expected_description}, but was #{actual.inspect}"
      end.join("\n")
    else
      @which_failure.message
    end
  end

  failure_message_when_negated do
    if @created_records.count == 1 && @attributes && @attribute_mismatches.none?
      "the block should not have created a #{klass} with attributes #{format_attributes_hash(@attributes).inspect}, but did"
    elsif @created_records.count == 1 && @which_block && !@which_failure
      "the newly created #{klass} should have failed an expectation in the given block, but didn't"
    elsif @created_records.count == 1
      "the block should not have created a #{klass}, but created #{@created_records.count}: #{@created_records.inspect}"
    else
      "the block created a #{klass} that matched all given criteria"
    end
  end

  def get_strategy(strategy)
    {
      timestamp: ActiveRecordBlockMatchers::TimestampStrategy,
    }.fetch(strategy)
  end

  def is_composable_matcher?(value)
    value.respond_to?(:failure_message_when_negated)
  end

  def format_attributes_hash(attributes)
    attributes.each_with_object({}) do |(field,value), memo|
      memo[field] = is_composable_matcher?(value) ? value.description : value
    end
  end
end

RSpec::Matchers.alias_matcher :create_a,  :create_a_new
RSpec::Matchers.alias_matcher :create_an, :create_a_new
