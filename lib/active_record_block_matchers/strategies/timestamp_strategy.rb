module ActiveRecordBlockMatchers
  class TimestampStrategy

    def initialize(block)
      @block = block
    end

    def new_records(classes)
      time_before = Time.current

      block.call

      classes.each_with_object({}) do |klass, new_records|
        new_records[klass] = klass.where("#{column_name} > ?", time_before).to_a
      end
    end

    private

    attr_reader :block

    def column_name
      @column_name ||= ActiveRecordBlockMatchers::Config.created_at_column_name
    end
  end
end
