require 'rails/generators/base'

module ActsAsReadable
  module Generators

class MigrationGenerator < Rails::Generators::Base

  source_root File.expand_path("../templates", __FILE__)

  def copy_initializer
  end

  def manifest
    invoke "active_record:acts_as_readable", ['readings']
  end

  def file_name
    "acts_as_readable_migration"
  end

  def rails5?
    Rails.version.start_with? '5'
  end

  def migration_version
    if rails5?
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end
  end
end
end
end
