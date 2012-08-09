class UserAddOnCache < ActiveRecord::Migration
  def self.up
    add_column :users, :addon_cache, :text
  end

  def self.down
    remove_column :users, :addon_cache
  end
end
