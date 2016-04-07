module ActiveRecordBlockMatchers
  class Config

    def self.configure
      yield self
    end

    def self.default_strategy
      @default_strategy || :id
    end

    def self.default_strategy=(strategy_key)
      @default_strategy = strategy_key.to_sym
    end

    def self.created_at_column_name
      @created_at_column_name || "created_at"
    end

    def self.created_at_column_name=(column_name)
      @created_at_column_name = column_name
    end

    def self.id_column_name
      @id_column_name || "id"
    end

    def self.id_column_name=(column_name)
      @id_column_name = column_name
    end
  end
end
