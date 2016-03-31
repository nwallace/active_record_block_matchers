RSpec::Matchers.define :create_records do |record_counts|
  include ActiveSupport::Inflector

  supports_block_expectations

  description do
    counts_strs = record_counts.map { |klass, count| count_str(klass, count) }
    "create #{counts_strs.join(", ")}"
  end

  chain(:with_attributes) do |attributes|
    # TODO: assert attributes has the right number of entries
    @expected_attributes = attributes
  end

  match do |block|
    time_before = Time.current

    block.call

    new_records =
      record_counts.keys.each_with_object({}) do |klass, new_records|
        column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
        new_records[klass] = klass.where("#{column_name} > ?", time_before).to_a
      end

    @incorrect_counts =
      new_records.each_with_object({}) do |(klass, new_records), incorrect|
        actual_count = new_records.count
        expected_count = record_counts[klass]
        if actual_count != expected_count
          incorrect[klass] = { expected: expected_count, actual: actual_count }
        end
      end
    if @expected_attributes
      @matched_records = Hash.new {|hash, key| hash[key] = []}
      @all_attributes = Hash.new {|hash, key| hash[key] = []}
      @incorrect_attributes =
        @expected_attributes.each_with_object(Hash.new {|hash, key| hash[key] = []}) do |(klass, expected_attributes), incorrect|
          @all_attributes[klass] = expected_attributes.map(&:keys).flatten.uniq
          expected_attributes.each do |expected_attrs|
            matched_record = (new_records.fetch(klass) - @matched_records[klass]).find do |record|
              expected_attrs.all? {|k,v| values_match?(v, record.public_send(k))}
            end
            if matched_record
              @matched_records[klass] << matched_record
            else
              incorrect[klass] << expected_attrs
            end
          end
        end
      @unmatched_records = @matched_records.map {|klass, records| [klass, new_records[klass] - records]}.to_h.reject {|k,v| v.empty?}
    end
    @incorrect_counts.blank? &&
      @incorrect_attributes.blank?
  end

  failure_message do
    if @incorrect_counts.present?
      @incorrect_counts.map do |klass, counts|
        "The block should have created #{count_str(klass, counts[:expected])}, but created #{counts[:actual]}."
      end.join(" ")
    elsif @incorrect_attributes.present?
      "The block should have created:\n" +
        @expected_attributes.map do |klass, attrs|
          "    #{attrs.count} #{klass} with these attributes:\n" +
          attrs.map{|a| "        #{a.inspect}"}.join("\n")
        end.join("\n") +
        "\nDiff:" +
        @incorrect_attributes.map do |klass, attrs|
          "\n    Missing #{attrs.count} #{klass} with these attributes:\n" +
          attrs.map{|a| "        #{a.inspect}"}.join("\n")
        end.join("\n") +
        @unmatched_records.map do |klass, records|
          "\n    Extra #{records.count} #{klass} with these attributes:\n" +
          records.map do |r|
            attrs = @all_attributes[klass].each_with_object({}) {|attr, attrs| attrs[attr] = r.public_send(attr)}
            "        #{attrs.inspect}"
          end.join("\n")
        end.join("\n")
    else
      "unknown error"
    end
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
