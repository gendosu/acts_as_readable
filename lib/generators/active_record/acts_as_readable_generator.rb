require 'rails/generators/active_record'

module ActiveRecord
  module Generators
class ActsAsReadableGenerator < ActiveRecord::Generators::Base

  source_root File.expand_path("../templates", __FILE__)

  def copy_initializer
  end

  def manifest
      migration_template 'migration.rb', "db/migrate/#{file_name}", migration_version: migration_version
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
