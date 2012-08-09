class AutoScheduledPlayerBudge < ActiveRecord::Migration
  def self.up
    add_column :player_budges, :lazy_scheduled, :boolean, :default => false
    PlayerBudge.update_all(:lazy_scheduled => false)
  end

  def self.down
    remove_column :player_budges, :lazy_scheduled
  end
end
