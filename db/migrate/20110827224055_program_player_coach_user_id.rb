class ProgramPlayerCoachUserId < ActiveRecord::Migration
  def self.up
    add_column :program_players, :coach_user_id, :integer
  end

  def self.down
    remove_column :program_players, :coach_user_id
  end
end
