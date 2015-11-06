# Build Status
[![Build Status](https://travis-ci.org/nwallace/active_record_block_matchers.svg)](https://travis-ci.org/nwallace/active_record_block_matchers)

# ActiveRecordBlockMatchers

Custom RSpec matchers for ActiveRecord record creation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_block_matchers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_block_matchers

## Custom Matchers

#### `create_a_new`

aliases: `create_a`, `create_an`

Example:

```ruby
expect { User.create! }.to create_a_new(User)
```

This can be very useful for controller tests:

```ruby
expect { post :create, user: user_params }.to create_a_new(User)
```

You can chain `.with_attributes` as well to define a list of values you expect the new object to have.  This works with both database attributes and computed values.

```ruby
expect { User.create!(username: "bob") }
  .to create_a_new(User)
  .with_attributes(username: "bob")
```

This is a great way to test ActiveReocrd hooks on your model.  For example, if your User model downcases all usernames before saving them to the database, you can test it like this:

```ruby
expect { User.create!(username: "BOB") }
  .to create_a_new(User)
  .with_attributes(username: "bob")
```

You can even use RSpec's [composable matchers][1]:

```ruby
expect { User.create!(username: "bob") }
  .to create_a_new(User)
  .with_attributes(username: a_string_starting_with("b"))
```

If you need to make assertions about things other than attribute equality, you can also chain `.which` with a block, and your block will receive the newly created record:

```ruby
expect { User.create!(username: "BOB", password: "BlueSteel45") }
  .to create_a_new(User)
  .which { |user|
    expect(user.encrypted_password).to be_present
    expect(AuthLibrary.authenticate("bob", "BlueSteel45")).to eq user
  }
```

**Gotcha Warning:** Be careful about your block syntax when chaining `.which` in your tests. If you write the above example with a `do...end`, the example will parse like this: `expect {...}.to(create_a_new(User).which) do |user| ... end`, so your block will not execute, and it may appear that your test is passing, when it is not.

This matcher relies on a `created_at` column existing on the given model class.  The name of this column can be configured via `ActiveRecordBlockMatchers::Config.created_at_column_name = "your_column_name"`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_record_block_matchers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[1]: https://www.relishapp.com/rspec/rspec-expectations/v/3-3/docs/composing-matchers
