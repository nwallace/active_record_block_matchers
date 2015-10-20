require "spec_helper"

RSpec.describe "`create_records` matcher" do

  it "passes if a new record of the given type was created by the block" do
    expect { Person.create! }.to create_records(Person => 1)
  end

  it "passes if multiple new records of the given type were created by the block" do
    expect {
      Person.create!
      Dog.create!
      Dog.create!
    }.to create_records(Person => 1, Dog => 2)
  end

  it "fails when nothing is created when it should have been" do
    expect {
      expect {}.to create_records(Person => 1)
    }.to raise_error("The block should have created 1 Person, but created 0.")
  end

  it "doesn't find records created before the block" do
    Person.create!
    expect {
      expect {}.to create_records(Person => 1)
    }.to raise_error("The block should have created 1 Person, but created 0.")
  end

  it "fails when too few records are created" do
    expect {
      expect { Person.create! }.to create_records(Person => 2)
    }.to raise_error("The block should have created 2 People, but created 1.")
  end

  it "reports all multiple failures if there were more than one" do
    expect {
      expect {
        Person.create!
        Person.create!
        Dog.create!
      }.to create_records(Person => 1, Dog => 2)
    }.to raise_error("The block should have created 1 Person, but created 2. The block should have created 2 Dogs, but created 1.")
  end

  it "can be negated" do
    expect { Person.create! }.not_to create_records(Person => 2)
    expect { Person.create!; Person.create! }.not_to create_records(Person => 1)
  end

  it "fails when negated if the same number of records were created as given" do
    expect {
      expect { Person.create! }.not_to create_records(Person => 1)
    }.to raise_error("The block should not have created 1 Person, but created 1.")
  end

  it "is aliased as `create`" do
    expect { Person.create! }.to create(Person => 1)
  end
end
