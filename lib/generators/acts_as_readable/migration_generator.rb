require 'rails/generators/base'

module ActsAsReadable
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      def copy_initializer
        invoke "active_record:acts_as_readable_migration", ['readings']
      end
    end
  end
end
