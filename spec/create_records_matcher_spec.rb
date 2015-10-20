require "spec_helper"

RSpec.describe "`create` matcher" do

  it "passes if a new record of the given type was created by the block" do
    expect { Person.create! }.to create(Person: 1)
  end

  it "passes if multiple new records of the given type were created by the block" do
    expect {
      Person.create!
      Dog.create!
      Dog.create!
    }.to create(
             Person: 1,
             Dog: 2)
  end

  it "fails when nothing is created" do
    expect {
      expect {}.to create(Person: 1)
    }.to raise_error('The block should have created 1 Person, but created 0.')
  end

  it "fails when wrong number is created" do
    expect {
      expect { Person.create! }.to create(Person: 2)
    }.to raise_error('The block should have created 2 People, but created 1.')
  end

  it "fails with multiple errors wrong number is created" do
    expect {
      expect {
        Person.create!
        Person.create!
        Dog.create!
      }.to create(Person: 1, Dog: 2)
    }.to raise_error('The block should have created 1 Person, but created 2. The block should have created 2 Dogs, but created 1.')
  end

  it "passes the negative" do
    expect { Person.create! }.to_not create(Person: 2)
  end

  it "passes the negative" do
    expect {
      expect { Person.create! }.to_not create(Person: 1)
    }.to raise_error('The block should not have created 1 Person, but created 1.')
  end
end
