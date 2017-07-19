# ActsAsReadable

ActsAsReadable allows you to create a generic relationship of items which can
be marked as 'read' by users. This is useful for forums or any other kind of
situation where you might need to know whether or not a user has seen a particular
model.

## Installation

generate migration  
create readings table

```
rails g acts_as_readable:migration
rails db:migrate
```

## Example

```
class Post < ActiveRecord::Base
  acts_as_readable
end

bob = User.find_by_name("bob")

bob.readings                      # => []

Post.unread_by(bob)               # => [<Post 1>,<Post 2>,<Post 3>...]
Post.read_by(bob)                 # => []

Post.find(1).read_by?(bob)        # => false
Post.find(1).read_by!(bob)        # => <Reading 1>
Post.find(1).read_by?(bob)        # => true
Post.find(1).readers              # => [<User bob>]

Post.unread_by(bob)               # => [<Post 2>,<Post 3>...]
Post.read_by(bob)                 # => [<Post 1>]

bob.readings                      # => [<Reading 1>]
```

Copyright (c) 2012 Culture Code Software Consulting. Released under the MIT license
