# Activerecord::WhereWithBlock

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/activerecord/where_with_block`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-where_with_block'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-where_with_block

## Usage

```ruby
# symbols refer to columns
puts User.where { :name == "homu" }.to_sql
# => SELECT "users".* FROM "users" WHERE "users"."name" = 'homu'

puts User.where { "homu" == :name }.to_sql
# => SELECT "users".* FROM "users" WHERE "users"."name" = 'homu'

# && is AND query
puts User.where { :name == "homu" && :age < 20 }.to_sql
# => SELECT "users".* FROM "users" WHERE "users"."name" = 'homu' AND "users"."age" < 20

# capture local variable and method
def age; 20 end
name = "homu"
puts User.where { :name == name || :age < age }.to_sql
# => SELECT "users".* FROM "users" WHERE ("users"."name" = 'homu' OR "users"."age" < 20)

# and instance variable
@name = "mami"
puts User.where { :name == @name }.to_sql
# => SELECT "users".* FROM "users" WHERE "users"."name" = 'mami'

# with associations
puts User.joins(:comments).where { :comments.text == "OK" && :name == "homu" }.to_sql
# => SELECT "users".*
#      FROM "users"
#     INNER
#      JOIN "comments"
#        ON "comments"."user_id" = "users"."id"
#     WHERE "comments"."text"    = 'OK'
#       AND "users"."name"       = 'homu'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/osyo-manga/gem-activerecord-where_with_block.
