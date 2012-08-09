class UserPhoneNeedsVerification < ActiveRecord::Migration
  def self.up
    add_column :users, :send_phone_verification, :boolean, :default => false
  end

  def self.down
    remove_column :users, :send_phone_verification
  end
end
