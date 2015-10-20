require "spec_helper"

RSpec.describe ActiveRecordBlockMatchers do
  it "has a version number" do
    expect(ActiveRecordBlockMatchers::VERSION).not_to be nil
  end

  describe "`create_a_new` matcher" do
    it "passes if a new record of the given type was created by the block" do
      expect { Person.create! }.to create_a_new(Person)
    end

    it "fails if no record of the given type was created by the block" do
      expect {
        expect {}.to create_a_new(Person)
      }.to raise_error
    end

    it "fails if more than one record of the given type was created by the block" do
      expect {
        expect { Person.create!; Person.create! }.to create_a_new(Person)
      }.to raise_error
    end

    it "doesn't find records created before the block" do
      Person.create!
      expect {
        expect {}.to create_a_new(Person)
      }.to raise_error
    end

    it "can chain `with_attributes`" do
      expect { Person.create!(first_name: "Pam", last_name: "Greer") }
        .to create_a_new(Person)
        .with_attributes(first_name: "Pam", last_name: "Greer", full_name: "Pam Greer")
    end

    it "fails if attributes don't match" do
      expect {
        expect { Person.create!(first_name: "Pam") }
          .to create_a_new(Person)
          .with_attributes(first_name: "Sally")
      }.to raise_error
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

    it "is aliases as `create_a`" do
      expect { Person.create! }.to create_a(Person)
    end

    it "is aliases as `create_an`" do
      expect { Person.create! }.to create_an(Person)
    end

    it "can be negated" do
      expect {}.not_to create_a(Person)
      expect {
        expect { Person.create! }.not_to create_a(Person)
      }.to raise_error
    end

    describe "failure message" do
      def capture_error
        begin
          yield
        rescue RSpec::Expectations::ExpectationNotMetError => e
          e
        end
      end

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

  describe "'create' matcher" do
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

  describe "configuration" do
    it "allows created_at_column_name to be configured" do
      described_class::Config.created_at_column_name = "create_timestamp"
      expect(described_class::Config.created_at_column_name).to eq "create_timestamp"
    end
  end
end
