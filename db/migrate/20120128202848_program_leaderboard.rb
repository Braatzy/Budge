class ProgramLeaderboard < ActiveRecord::Migration
  def self.up
    add_column :programs, :leaderboard_trait_id, :integer
    add_column :programs, :leaderboard_trait_direction, :integer
  end

  def self.down
    remove_column :programs, :leaderboard_trait_id
    remove_column :programs, :leaderbaord_trait_direction
  end
end
