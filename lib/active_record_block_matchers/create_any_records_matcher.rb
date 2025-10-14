RSpec::Matchers.define :create_any_records do |*types|
  supports_block_expectations

  description do
    "create #{types.map(&:name).to_sentence}"
  end

  match do |options={}, block|
    @verbose = options.delete(:verbose)
    fetching_strategy =
      ActiveRecordBlockMatchers::Strategies.for_key(options[:strategy]).new(block)

    @new_records = fetching_strategy.new_records(types)

    @missing_types =
      @new_records.each_with_object([]) do |(klass, new_records), missing|
        missing << klass if new_records.none?
      end

    @missing_types.empty?
  end

  failure_message do
    "The block should have created at least one #{@missing_types.map(&:name).to_sentence}, but created none."
  end

  failure_message_when_negated do
    @new_records.except(*@missing_types).map do |klass, new_records|
      details = @verbose ? ":\n    #{new_records.join("\n    ")}" : "."
      "The block should not have created any #{klass.name}, but created #{new_records.count}#{details}"
    end.join("\n")
  end
end

RSpec::Matchers.alias_matcher :create_any, :create_any_records
