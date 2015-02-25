module ActiveRecordBlockMatchers
  class Config

    def self.created_at_column_name
      @created_at_column_name || "created_at"
    end

    def self.created_at_column_name=(column_name)
      @created_at_column_name = column_name
    end
  end
end
