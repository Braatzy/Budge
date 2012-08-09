class ProgramPlayerSubscribedAt < ActiveRecord::Migration
  def self.up
    add_column :program_players, :program_coach_subscribed_at, :date
  end

  def self.down
    remove_column :program_players, :program_coach_subscribed_at
  end
end
