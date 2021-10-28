# frozen_string_literal: true

require "activerecord-where_with_block"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

temp_io = $stdout
$stdout = StringIO.new

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.integer :age
    t.boolean :active
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.string :text
    t.integer :user_id
    t.timestamps
  end
end

$stdout = temp_io

class User < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :user
end
