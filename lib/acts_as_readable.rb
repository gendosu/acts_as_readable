require 'acts_as_readable/acts_as_readable'
require 'acts_as_readable/acts_as_reader'
require 'acts_as_readable/reading'

ActiveRecord::Base.send :extend, ActsAsReadable::ActMethod
ActiveRecord::Base.send :extend, ActsAsReader::ActMethod
