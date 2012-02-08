$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'active_record'
require 'acts_as_readable'

ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "acts_as_readable_test")

ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.datetime :comments_read_at
  end

  create_table :comments, :force => true do |t|
    t.timestamps
  end

  create_table :readings, :force => true do |t|
    t.belongs_to :readable, :polymorphic => true
    t.belongs_to :user
    t.string :state, :null => false, :default => 'read'
    t.timestamps
  end
end

class User < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
  acts_as_readable :cache => :comments_read_at
end
