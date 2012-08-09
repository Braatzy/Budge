class UserTraitActive < ActiveRecord::Migration
  def self.up
    add_column :user_traits, :active, :boolean, :default => false
  end

  def self.down
    remove_column :user_traits, :active
  end
end
