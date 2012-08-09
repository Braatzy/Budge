class UserWithings < ActiveRecord::Migration
  def self.up
    add_column :users, :withings_user_id, :string
    add_column :users, :withings_public_key, :string
    add_column :users, :withings_username, :string
    add_column :users, :withings_subscription_renew_by, :date
  end

  def self.down
    remove_column :users, :withings_user_id, :string
    remove_column :users, :withings_public_key
    remove_column :users, :withings_username
    remove_column :users, :withings_subscription_renew_by
  end
end
