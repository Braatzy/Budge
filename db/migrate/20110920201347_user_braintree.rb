class UserBraintree < ActiveRecord::Migration
  def self.up
    add_column :users, :has_braintree, :boolean, :default => false
  end

  def self.down
    remove_column :users, :has_braintree
  end
end
