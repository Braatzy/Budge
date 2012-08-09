class UserBudgeRemoteName < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :remote_user_name, :string
  end

  def self.down
    remove_column :user_budges, :remote_user_name
  end
end
