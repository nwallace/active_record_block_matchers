require "spec_helper"

RSpec.describe ActiveRecordBlockMatchers do
  it "has a version number" do
    expect(ActiveRecordBlockMatchers::VERSION).not_to be nil
  end

  describe "configuration" do
    before do
      @original_column_name = described_class::Config.created_at_column_name
      described_class::Config.created_at_column_name = "create_timestamp"
    end

    after  { described_class::Config.created_at_column_name = @original_column_name }

    it "allows created_at_column_name to be configured" do
      original_column_name = described_class::Config.created_at_column_name
      described_class::Config.created_at_column_name = "create_timestamp"
      begin
        expect(described_class::Config.created_at_column_name).to eq "create_timestamp"
      ensure
        described_class::Config.created_at_column_name = original_column_name
      end
    end
  end
end
