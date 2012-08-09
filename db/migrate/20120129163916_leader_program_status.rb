class LeaderProgramStatus < ActiveRecord::Migration
  def self.up
    add_column :leaders, :program_status, :string
    add_column :leaders, :last_played_days_ago, :integer
  end

  def self.down
    remove_column :leaders, :program_status
    remove_column :leaders, :last_played_days_ago
  end
end
