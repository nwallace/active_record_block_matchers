require "spec_helper"

RSpec.describe "`create_a_new` matcher" do

  it "passes if a new record of the given type was created by the block" do
    expect { Person.create! }.to create_a_new(Person)
  end

  it "fails if no record of the given type was created by the block" do
    expect {
      expect {}.to create_a_new(Person)
    }.to raise_error RSpec::Expectations::ExpectationNotMetError
  end

  it "fails if more than one record of the given type was created by the block" do
    expect {
      expect { Person.create!; Person.create! }.to create_a_new(Person)
    }.to raise_error RSpec::Expectations::ExpectationNotMetError
  end

  it "doesn't find records created before the block" do
    Person.create!
    expect {
      expect {}.to create_a_new(Person)
    }.to raise_error RSpec::Expectations::ExpectationNotMetError
  end

  it "can chain `with_attributes`" do
    expect { Person.create!(first_name: "Pam", last_name: "Greer") }
      .to create_a_new(Person)
      .with_attributes(first_name: "Pam", last_name: "Greer", full_name: "Pam Greer")
  end

  it "can use RSpec's composable matchers to verify attributes" do
    expect { Person.create!(first_name: "Ginger") }
      .to create_a_new(Person)
      .with_attributes(first_name: a_string_starting_with("G"))
  end

  it "fails if attributes don't match" do
    expect {
      expect { Person.create!(first_name: "Pam") }
        .to create_a_new(Person)
        .with_attributes(first_name: "Sally")
    }.to raise_error RSpec::Expectations::ExpectationNotMetError
  end

  it "can chain `which` that takes a block" do
    block_was_called = false
    expect { Person.create!(first_name: "Pam", last_name: "Greer") }
      .to create_a_new(Person)
      .which { |person|
        expect(person.full_name).to eq "Pam Greer"
        block_was_called = true
      }
    expect(block_was_called).to be_truthy
  end

  it "is aliased as `create_a`" do
    expect { Person.create! }.to create_a(Person)
  end

  it "is aliased as `create_an`" do
    expect { Person.create! }.to create_an(Person)
  end

  it "can be negated" do
    expect {}.not_to create_a(Person)
    expect {
      expect { Person.create! }.not_to create_a(Person)
    }.to raise_error RSpec::Expectations::ExpectationNotMetError
  end

  describe "failure message" do
    it "explains if no record was created" do
      error = capture_error do
        expect {}.to create_a(Person)
      end

      expect(error.message).to eq "the block should have created 1 Person, but created 0"
    end

    it "explains if more than one record was created" do
      error = capture_error do
        expect { Person.create!; Person.create! }.to create_a(Person)
      end

      expect(error.message).to eq "the block should have created 1 Person, but created 2"
    end

    it "explains if record was created, but attributes did not match" do
      error = capture_error do
        expect { Person.create! }.to create_a(Person)
          .with_attributes(first_name: "Jill")
      end

      expect(error.message).to eq 'Expected :first_name to be "Jill", but was nil'
    end

    it "explains if record was created, but attributes did not match a composable matcher" do
      error = capture_error do
        expect { Person.create! }.to create_a(Person)
          .with_attributes(first_name: a_string_starting_with("J"))
      end

      expect(error.message).to eq 'Expected :first_name to be a string starting with "J", but was nil'
    end

    it "explains if record was created, but `which` block raised an error" do
      error = capture_error do
        expect { Person.create! }.to create_a(Person)
          .which { |p| expect(p.first_name).to eq "Jill" }
      end

      expect(error.message).to match /expected: "Jill"\s+got: nil/m
    end

    context "when negated" do
      it "explains if a record was created" do
        error = capture_error do
          expect { Person.create! }.not_to create_a(Person)
        end

        expect(error.message).to start_with "the block should not have created a Person, but created 1"
      end

      it "explains if a record was created that matched the given attributes" do
        error = capture_error do
          expect { Person.create!(first_name: "Jill") }
            .not_to create_a(Person)
            .with_attributes(first_name: "Jill")
        end

        expect(error.message).to eq 'the block should not have created a Person with attributes {:first_name=>"Jill"}, but did'
      end

      it "explains if a record was created that matched the given attributes with a composable matcher" do
        error = capture_error do
          expect { Person.create!(first_name: "Jill") }
            .not_to create_a(Person)
            .with_attributes(first_name: a_string_starting_with("J"))
        end

        expect(error.message).to eq 'the block should not have created a Person with attributes {:first_name=>"a string starting with \"J\""}, but did'
      end

      it "explains if a record was created and `which` block didn't raise an error" do
        error = capture_error do
          expect { Person.create!(first_name: "Jill") }
            .not_to create_a(Person)
            .which { |p| expect(p.first_name).to eq "Jill" }
        end

        expect(error.message).to eq "the newly created Person should have failed an expectation in the given block, but didn't"
      end
    end
  end
end
