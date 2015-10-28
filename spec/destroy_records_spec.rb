require "spec_helper"

RSpec.describe "`destroy_records` matcher" do

  before(:each) do
    Person.with_deleted.each {|person| person.really_destroy!}
    Dog.with_deleted.each {|dog| dog.really_destroy!}
    2.times do
      Person.create!
      Dog.create!
    end
  end

  it "passes if a record of the given type was deleted by the block" do
    expect { Person.first.destroy }.to destroy_records(Person => 1)
  end

  it "passes if multiple new records of the given type were created by the block" do
    expect {
      Person.first.destroy
      Dog.first.destroy
      Dog.first.destroy
    }.to destroy_records(Person => 1, Dog => 2)
  end

  it "fails when nothing is destroyed when it should have been" do
    expect {
      expect {}.to destroy_records(Person => 1)
    }.to raise_error("The block should have destroyed 1 Person, but destroyed 0.")
  end

  it "fails when too few records are destroyed" do
    expect {
      expect { Person.first.destroy }.to destroy_records(Person => 2)
    }.to raise_error("The block should have destroyed 2 People, but destroyed 1.")
  end

  it "reports all multiple failures if there were more than one" do
    expect {
      expect {
        Person.first.destroy
        Person.first.destroy
        Dog.first.destroy
      }.to destroy_records(Person => 1, Dog => 2)
    }.to raise_error("The block should have destroyed 1 Person, but destroyed 2. The block should have destroyed 2 Dogs, but destroyed 1.")
  end

  it "can be negated" do
    expect { Person.first.destroy }.not_to destroy_records(Person => 2)
  end

  it "fails when negated if the same number of records were destroyed as given" do
    expect {
      expect { Person.first.destroy }.not_to destroy_records(Person => 1)
    }.to raise_error("The block should not have destroyed 1 Person, but destroyed 1.")
  end

  it "is aliased as `destroy`" do
    expect { Person.first.destroy }.to destroy(Person => 1)
  end
  
  it "is aliased as `destroy_records`" do
    expect { Person.first.destroy }.to destroy_records(Person => 1)
  end
end
