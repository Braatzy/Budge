class CoachBatchEmail < ActiveRecord::Migration
  def self.up
    add_column :program_players, :coach_flag, :integer
  end

  def self.down
    remove_column :program_players, :coach_flag
  end
end
