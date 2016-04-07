RSpec.shared_examples_for "a new records strategy" do

  describe "#new_records" do
    it "returns records of the given type that are created during the block" do
      subject = described_class.new(-> { Person.create! })
      records = subject.new_records([Person])
      expect(records).to match(Person => [an_instance_of(Person)])
    end

    it "returns the records for all the classes asked for" do
      subject = described_class.new(-> { Person.create!; Person.create!; Dog.create! })
      records = subject.new_records([Person, Dog])
      expect(records).to match(
        Person => [an_instance_of(Person), an_instance_of(Person)],
        Dog => [an_instance_of(Dog)],
      )
    end

    it "might return no records" do
      subject = described_class.new(-> {})
      records = subject.new_records([Person])
      expect(records).to eq(Person => [])
    end

    it "doesn't return records created before the call" do
      Person.create!
      subject = described_class.new(-> {})
      records = subject.new_records([Person])
      expect(records).to eq(Person => [])
    end
  end
end
