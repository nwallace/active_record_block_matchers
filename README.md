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

## Usage

```ruby
RSpec.describe PostsController do
  describe "POST create" do
    let(:jill) { User.create!(name: "Jill Sherman") }
    let(:post_attrs) { { author: jill, title: "10 Reasons I Don't Hate ActiveRecordBlockMatchers", body: "Further link bait goes here..." } }

    it "creates a new blog post" do
      expect { post :create, post: post_attrs }
        .to create_a_new(post)
        .with_attributes(post_attrs)
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_record_block_matchers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
