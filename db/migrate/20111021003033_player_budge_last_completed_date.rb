class PlayerBudgeLastCompletedDate < ActiveRecord::Migration
  def self.up
    add_column :player_budges, :last_completed_date, :date
    add_column :player_budges, :streak_broken, :boolean, :default => false
  end

  def self.down
    remove_column :player_budges, :last_completed_date
    remove_column :player_budges, :streak_broken
  end
end
