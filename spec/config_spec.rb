require "spec_helper"

RSpec.describe ActiveRecordBlockMatchers::Config do

  {
    default_strategy: :id,
    created_at_column_name: "created_at",
    id_column_name: "id",
  }.each do |var, default_value|
    it "defaults #{var.inspect} to #{default_value.inspect}" do
      expect(described_class.public_send(var)).to eq default_value
    end

    it "allows #{var.inspect} to be configured" do
      original_value = described_class.public_send(var)
      begin
        described_class.public_send("#{var}=", :new_value)
        expect(described_class.public_send(var)).to eq :new_value
      ensure
        described_class.public_send("#{var}=", original_value)
      end
    end
  end

  describe ".configure" do
    it "yields itself for configuration" do
      original_default_strategy = described_class.default_strategy
      begin
        described_class.configure do |config|
          expect(config).to eq described_class
          config.default_strategy = :timestamp
        end
        expect(described_class.default_strategy).to eq :timestamp
      ensure
        described_class.default_strategy = original_default_strategy
      end
    end
  end
end
