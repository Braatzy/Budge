class ProgramVictorious < ActiveRecord::Migration
  def self.up
    rename_column :programs, :percent_successful, :percent_victorious
  end

  def self.down
    rename_column :programs, :percent_victorious, :percent_successful
  end
end
