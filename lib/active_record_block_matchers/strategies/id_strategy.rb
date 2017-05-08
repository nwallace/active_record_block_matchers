module ActiveRecordBlockMatchers
  class IdStrategy

    def initialize(block)
      @block = block
    end

    def new_records(classes)
      ids_before = classes.each_with_object({}) do |klass, ids_before|
        ids_before[klass] = klass.select("MAX(#{column_name}) as max_id").order("max_id").first.try(:max_id) || 0
      end

      block.call

      classes.each_with_object({}) do |klass, new_records|
        id_before = ids_before[klass]
        new_records[klass] = klass.where("#{column_name} > ?", id_before).to_a
      end
    end

    private

    attr_reader :block

    def column_name
      @column_name ||= ActiveRecordBlockMatchers::Config.id_column_name
    end
  end
end
