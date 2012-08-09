class PlayerBudgeEndedEarly < ActiveRecord::Migration
  def self.up
    add_column :player_budges, :ended_early, :boolean, :default => false
  end

  def self.down
    remove_column :player_budges, :ended_early
  end
end
