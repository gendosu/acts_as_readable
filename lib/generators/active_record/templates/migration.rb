class ActsAsReadableMigration < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :readings do |t|
      t.string :readable_type
      t.integer :readable_id
      t.integer :user_id
      t.string :state, :null => false, :default => :read
      t.timestamps
    end

    add_index :readings, [:readable_id, :readable_type, :user_id], :unique => true
  end

  def self.down
    drop_table :readings
  end
end
