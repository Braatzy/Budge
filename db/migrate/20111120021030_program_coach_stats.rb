class ProgramCoachStats < ActiveRecord::Migration
  def self.up
    remove_column :program_coaches, :num_incomplete
    remove_column :program_coaches, :num_lost
    remove_column :program_coaches, :num_dropped_out
    remove_column :program_coaches, :percent_complete
    add_column :program_coaches, :percent_completed, :decimal, :precision => 5, :scale => 2

    add_column :program_coaches, :num_scheduled, :integer, :default => 0
    add_column :program_coaches, :num_budgeless, :integer, :default => 0
    
    add_column :program_players, :program_coach_rating, :integer
    add_column :program_players, :program_coach_testimonial, :text
    add_column :program_players, :program_coach_recommended, :boolean
    add_column :program_players, :program_coach_rated_at, :datetime
    
  end

  def self.down
    add_column :program_coaches, :num_incomplete, :integer, :default => 0
    add_column :program_coaches, :num_lost, :integer, :default => 0
    add_column :program_coaches, :num_dropped_out, :integer, :default => 0
    remove_column :program_coaches, :percent_completed
    add_column :program_coaches, :percent_complete, :decimal, :precision => 5, :scale => 2

    remove_column :program_coaches, :num_scheduled
    remove_column :program_coaches, :num_budgeless
    
    remove_column :program_players, :program_coach_rating
    remove_column :program_players, :program_coach_testimonial
    remove_column :program_players, :program_coach_recommended
    remove_column :program_players, :program_coach_rated_at
  end
end
