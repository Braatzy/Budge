class NagMode < ActiveRecord::Migration
  def self.up
    remove_column :users, :nag_mode
    add_column :users, :nag_mode, :integer, :default => 0
    add_column :users, :emergency_phone, :string
    add_column :users, :emergency_phone_normalized, :string
    add_column :users, :emergency_phone_verified, :string
    
    User.update_all(:nag_mode => 0)
  end

  def self.down
    remove_column :users, :nag_mode
    add_column :users, :nag_mode, :boolean, :default => true
    remove_column :users, :emergency_phone
    remove_column :users, :emergency_phone_normalized
    remove_column :users, :emergency_phone_verified
  end
end
