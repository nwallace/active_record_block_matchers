module ActiveRecordBlockMatchers
  module SpecUtilities
    def capture_error
      begin
        yield
      rescue RSpec::Expectations::ExpectationNotMetError => e
        e
      end
    end
  end
end
