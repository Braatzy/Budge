class CreateProgramSteps < ActiveRecord::Migration
  def self.up
    create_table :program_steps do |t|
    
      # Step details
      t.string :program_id
      t.text :coach_message
      t.string :duration
      t.integer :num_budge_templates
      t.integer :total_players, :default => 0
      t.boolean :on_success_path, :default => false # There should be at least 1 path through program with all success.

      # Step family tree info (optional)
      t.integer :parent_id # Which step does this come after? (parent_
      t.integer :position, :default => 1000 # Position amongst all steps within this parent_id branch (order)
      t.string :progress # "forward", "backward", nil (gender)
      t.integer :generation, :default => 1 # How deep this step is (officially) (1 + self.parent.step_depth)

      # Outcome stats from all player_steps 
      # In order to judge effectiveness of this step
      t.integer :num_active, :default => 0
      t.integer :num_incomplete, :default => 0
      t.integer :num_lost, :default => 0
      t.integer :num_dropped_out, :default => 0
      t.integer :num_failed, :default => 0
      t.integer :num_partial, :default => 0
      t.integer :num_success, :default => 0

      # Outcome responses (see PlayerStep for all codes)
      # active = no action required until past the needs_coach_at timestamp (then moves to incomplete)
      # incomplete  = always contact the coach, they contact and manually move player to active, or moves to lost after needs_coach_at timestamp
      # - lost: always contact the coach, move to failed
      # dropped_out = always recommend new program
      # snoozed = always keep active and move needs_coach_at out another X days
      # skipped = go to next step that they haven't done yet, sorted by priority (or contact coach if there isn't one)
      
        # Repeat or go back to step_id X?
        t.string :failed_response_token, :default => 'TBD'
        t.integer :failed_id
  
        # Repeat or go back to step_id X or continue to next step?
        t.string :partial_response_token, :default => 'REP'
        t.integer :partial_id
  
        t.string :success_response_token, :default => 'TBD'
        t.integer :success_id


      # For more complicated triggers than "immediate"
      t.string :trigger_token
      t.text :trigger_data

      t.timestamps
    end
  end

  def self.down
    drop_table :program_steps
  end
end
