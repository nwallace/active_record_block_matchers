module ActiveRecordBlockMatchers
  class Strategies

    def self.all_strategies
      @all_strategies ||= {
        id: IdStrategy,
        timestamp: TimestampStrategy,
      }
    end

    def self.default
      get_strategy!(Config.default_strategy)
    end

    def self.for_key(strategy_key)
      if strategy_key.nil?
        default
      else
        get_strategy!(strategy_key)
      end
    end

    private

    def self.get_strategy!(strategy_key)
      all_strategies.fetch(strategy_key)
    rescue KeyError
      raise UnknownStrategyError, "#{strategy_key.inspect} is not a known strategy (known strategies are #{all_strategies.keys})"
    end
  end
end
