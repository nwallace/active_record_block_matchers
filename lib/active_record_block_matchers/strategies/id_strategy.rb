module ActiveRecordBlockMatchers
  class IdStrategy

    def initialize(block)
      @block = block
    end

    def new_records(klass)
      id_before = klass.select("MAX(#{column_name}) as max_id").first.try(:max_id) || 0

      block.call

      klass.where("#{column_name} > ?", id_before)
    end

    private

    attr_reader :block

    def column_name
      @column_name ||= ActiveRecordBlockMatchers::Config.id_column_name
    end
  end
end
