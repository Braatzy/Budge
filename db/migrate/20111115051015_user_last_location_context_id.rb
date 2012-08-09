class UserLastLocationContextId < ActiveRecord::Migration
  def self.up
    add_column :users, :last_location_context_id, :integer
  end

  def self.down
    remove_column :users, :last_location_context_id
  end
end
