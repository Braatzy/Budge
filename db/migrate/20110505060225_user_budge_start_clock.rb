class UserBudgeStartClock < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :expired, :boolean, :default => false
    add_column :user_budges, :start_clock, :datetime
    add_column :user_budges, :end_clock, :datetime
    add_column :user_budges, :num_comments, :integer, :default => 0
  end

  def self.down
    remove_column :user_budges, :expired
    remove_column :user_budges, :start_clock
    remove_column :user_budges, :end_clock
    remove_column :user_budges, :num_comments    
  end
end
