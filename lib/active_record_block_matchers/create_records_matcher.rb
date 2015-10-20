RSpec::Matchers.define :create_records do |record_counts|
  include ActiveSupport::Inflector

  supports_block_expectations

  description do
    counts_strs = record_counts.map { |klass, count| count_str(klass, count) }
    "create #{counts_strs.join(", ")}"
  end

  match do |block|
    time_before = Time.current

    block.call

    @incorrect_record_counts =
      record_counts.each_with_object({}) do |(klass, expected_count), incorrect_record_counts|
        column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
        actual_count = klass.where("#{column_name} > ?", time_before).count
        if actual_count != expected_count
          incorrect_record_counts[klass] = { expected: expected_count, actual: actual_count }
        end
      end
    @incorrect_record_counts.empty?
  end

  failure_message do
    @incorrect_record_counts.map do |klass, counts|
      "The block should have created #{count_str(klass, counts[:expected])}, but created #{counts[:actual]}."
    end.join(" ")
  end

  failure_message_when_negated do
    record_counts.map do |klass, expected_count|
      "The block should not have created #{count_str(klass, expected_count)}, but created #{expected_count}."
    end.join(" ")
  end

  def count_str(klass, count)
    "#{count} #{klass.name.pluralize(count)}"
  end
end

RSpec::Matchers.alias_matcher :create, :create_records
