module ActiveRecordBlockMatchers
  class TimestampStrategy

    def initialize(block)
      @block = block
    end

    def new_records(klass)
      time_before = Time.current

      block.call

      klass.where("#{column_name} > ?", time_before)
    end

    private

    attr_reader :block

    def column_name
      @column_name ||= ActiveRecordBlockMatchers::Config.created_at_column_name
    end
  end
end
