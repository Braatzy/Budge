class AddStatusColumntoUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :string, :default => 'unknown'
    User.update_state_for_all_users
  end

  def self.down
    remove_column :users, :status
  end
end
