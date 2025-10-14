require "spec_helper"

RSpec.describe "`create_any_records` matcher" do

  it "passes if a new record of the given type was created by the block" do
    expect { Person.create! }.to create_any_records(Person)
  end

  it "passes if multiple new records of the given type were created by the block" do
    expect {
      Person.create!
      Dog.create!
      Dog.create!
    }.to create_any_records(Person, Dog)
  end

  it "fails when nothing is created when it should have been" do
    expect {
      expect {}.to create_any_records(Person)
    }.to raise_error("The block should have created at least one Person, but created none.")
  end

  it "doesn't find records created before the block" do
    Person.create!
    expect {
      expect {}.to create_any_records(Person)
    }.to raise_error("The block should have created at least one Person, but created none.")
  end

  it "fails when records weren't created for every specified class" do
    expect {
      expect { Person.create! }.to create_any_records(Person, Dog)
    }.to raise_error("The block should have created at least one Dog, but created none.")
  end

  it "reports all multiple failures if there were more than one" do
    expect {
      expect {}.to create_any_records(Person, Dog)
    }.to raise_error("The block should have created at least one Person and Dog, but created none.")
  end

  it "can be negated" do
    expect { 6 }.not_to create_any_records(Person)
  end

  it "fails when negated if any records were created" do
    expect {
      expect { Person.create! }.not_to create_any_records(Person)
    }.to raise_error("The block should not have created any Person, but created 1.")
  end

  it "fails with a more detailed message when negated and told to be verbose if any records were created" do
    expect {
      expect { Person.create! }.not_to create_any_records(Person, verbose: true)
    }.to raise_error(/The block should not have created any Person, but created 1:\n    #<Person:\w+>/)
  end

  it "is aliased as `create_any`" do
    expect { Person.create! }.to create_any(Person)
  end

  it "doesn't care if the block creates unspecified records" do
    expect {
      Person.create!(first_name: "Pam", last_name: "Morrison")
      Dog.create!(name: "Poppins")
    }.to create(Dog => 1)
      .with_attributes(Dog => [{name: "Poppins"}])
  end
end
