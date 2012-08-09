class UserActionNumAndSum < ActiveRecord::Migration
  def self.up
    rename_column :user_actions, :num_times_done, :sum_of_amount
    add_column :user_actions, :num_days_done, :integer, :default => 0
  end

  def self.down
    rename_column :user_actions, :sum_of_amount, :num_times_done
    remove_column :user_actions, :num_days_done
  end
end
