require "spec_helper"

RSpec.describe ActiveRecordBlockMatchers::IdStrategy do

  let(:the_proc) { -> { Person.create! } }

  describe "initialization" do
    it "takes a proc" do
      expect { described_class.new(the_proc) }.not_to raise_error
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  describe "#new_records" do
    it "returns records of the given type that are created during the block" do
      subject = described_class.new(the_proc)
      records = subject.new_records([Person])
      expect(records[Person].count).to eq 1
    end

    it "might return no records" do
      subject = described_class.new(-> {})
      records = subject.new_records([Person])
      expect(records[Person].count).to eq 0
    end

    it "doesn't return records created before the call" do
      Person.create!
      subject = described_class.new(-> {})
      records = subject.new_records([Person])
      expect(records[Person].count).to eq 0
    end

    it "can be called multiple times to return records of different types"
  end
end
