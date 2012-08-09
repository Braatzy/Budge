class UpdateCheckins < ActiveRecord::Migration
  def self.up
    change_column :checkins, :trait_id, :integer, :null => false
    change_column :checkins, :user_trait_id, :integer, :null => false
    remove_column :checkins, :completed_action
  end

  def self.down
    change_column :checkins, :trait_id, :integer, :null => true
    change_column :checkins, :user_trait_id, :integer, :null => true
    add_column :checkins, :completed_action, :boolean, :default => false
  end
end
