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

  it "can chain `with_attributes`" do
    expect {
      Person.create!(first_name: "Pam", last_name: "Greer")
      Person.create!(first_name: "Bubba", last_name: "Conner")
      Dog.create!(name: "Bucket", breed: "Terrier")
    }.to create(Person => 2, Dog => 1)
      .with_attributes(
        Person => [
          {first_name: "Pam", last_name: "Greer", full_name: "Pam Greer"},
          {first_name: "Bubba", last_name: "Conner", full_name: "Bubba Conner"},
        ],
        Dog => [
          {name: "Bucket", breed: "Terrier"}
        ],
      )
  end

  it "fails if expected attributes don't match" do
    expect {
      expect {
        Person.create!(first_name: "Pam", last_name: "Morrison")
        Person.create!(first_name: "Shay")
        Person.create!(first_name: "Carter", last_name: "Townes")
        Dog.create!(name: "Poppins")
      }.to create(Person => 3, Dog => 1)
        .with_attributes(Person => [
          {first_name: "Pam", last_name: "Morrison"},
          {first_name: "Boris"},
          {first_name: "Hugh", last_name: "Townes"},
        ],
        Dog => [
          {name: "Poppins"}
        ])
    }.to raise_error(%Q|The block should have created:
    3 Person with these attributes:
        {:first_name=>"Pam", :last_name=>"Morrison"}
        {:first_name=>"Boris"}
        {:first_name=>"Hugh", :last_name=>"Townes"}
    1 Dog with these attributes:
        {:name=>"Poppins"}
Diff:
    Missing 2 Person with these attributes:
        {:first_name=>"Boris"}
        {:first_name=>"Hugh", :last_name=>"Townes"}
    Extra 2 Person with these attributes:
        {:first_name=>"Shay", :last_name=>nil}
        {:first_name=>"Carter", :last_name=>"Townes"}|)
  end

  it "allows you to not specify attributes for all record types" do
    expect {
      Person.create!(first_name: "Pam", last_name: "Morrison")
      Dog.create!(name: "Poppins")
    }.to create(Person => 1, Dog => 1)
      .with_attributes(Dog => [{name: "Poppins"}])
  end

  it "doesn't care if the block creates unspecified records" do
    expect {
      Person.create!(first_name: "Pam", last_name: "Morrison")
      Dog.create!(name: "Poppins")
    }.to create(Dog => 1)
      .with_attributes(Dog => [{name: "Poppins"}])
  end

  it "uses composable matchers for comparing attributes" do
    expect {
      Dog.create!(name: "Seymour")
    }.to create(Dog => 1)
      .with_attributes(Dog => [{name: a_string_starting_with("S")}])
  end

  it "raises an error if the number of attributes specified for a class doesn't match the number of records specified" do
    expect {
      expect { Person.create!(first_name: "Ginger") }
        .to create(Person => 1)
        .with_attributes(Person => [])
    }.to raise_error ArgumentError, "Specified the block should create 1 Person, but provided 0 Person attribute specifications"
  end

  it "is okay with blank attribute specifications" do
    expect { Person.create! }
      .to create(Person => 1)
      .with_attributes(Person => [{}])
  end

  it "can chain `which` that takes a block and yields the new records" do
    block_was_called = false
    expect {
      Dog.create!(name: "Ollie")
      Person.create!(first_name: "Gary", last_name: "Hooper")
    }.to create(Person => 1, Dog => 1)
      .which { |records|
        expect(records).to eq(Person => Person.where(first_name: "Gary").to_a, Dog => Dog.where(name: "Ollie").to_a)
        block_was_called = true
      }
    expect(block_was_called).to be_truthy
  end

  it "explains if records were created, but `which` block raised an error" do
    error = capture_error do
      expect { Person.create! }.to create_records(Person => 1)
        .which { |records| expect(records[Person].first.first_name).to eq "Jill" }
    end

    expect(error.message).to match /expected: "Jill"\s+got: nil/m
  end
end
