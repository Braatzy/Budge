class UserActionStartEndClocks < ActiveRecord::Migration
  def up
    remove_column :user_actions, :start_clock
    remove_column :user_actions, :end_clock
    remove_column :user_actions, :duration
    remove_column :user_actions, :per_period
  end

  def down
    add_column :user_actions, :start_clock, :datetime
    add_column :user_actions, :end_clock, :datetime
    add_column :user_actions, :duration, :string
    add_column :user_actions, :per_period, :integer
  end
end
