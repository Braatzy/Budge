class UserBudgeLastCheckin < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :last_checkin_at, :datetime
  end

  def self.down
    remove_column :user_budges, :last_checkin_at
  end
end
