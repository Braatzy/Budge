class UserAddonMultiples < ActiveRecord::Migration
  def self.up
    add_column :user_addons, :num_owned, :integer, :default => 1
    add_column :user_addons, :given_to, :text
    add_column :user_addons, :given_by, :text
  end

  def self.down
    remove_column :user_addons, :num_owned
    remove_column :user_addons, :given_to
    remove_column :user_addons, :given_by
  end
end
