class UserContactOnDev < ActiveRecord::Migration
  def self.up
    add_column :users, :contact_on_dev, :boolean, :default => false
  end

  def self.down
    remove_column :users, :contact_on_dev
  end
end
