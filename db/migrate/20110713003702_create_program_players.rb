class CreateProgramPlayers < ActiveRecord::Migration
  def self.up
    create_table :program_players do |t|
      t.integer :program_id
      t.integer :user_id
      
      # Program status info (actual status is in the player_step object)
      t.integer :player_step_id  # Current step
      t.string :outcome_token # Also in PlayerStep (denormalized)
      t.datetime :outcome_since 
      t.datetime :needs_coach_at # When the coach needs to come intervene

      # self.player_steps stats
      # t.integer :num_incomplete # 1 if they are currently in need of help (not needed, as outcome token will reflect this)
      # In order to judge status for this project for this player
      t.integer :num_failed     # Number of steps that they've failed in this program
      t.integer :num_partial    # Number of steps that have had partial success in this program
      t.integer :num_success    # Number of steps that they successfully completed
      t.integer :num_skipped    # Number of times that they've skipped steps
      t.integer :num_snooze     # Number of times that they've snoozed a step

      t.timestamps
    end

    add_index :program_players, [:program_id, :needs_coach_at]
  end

  def self.down
    drop_table :program_players
  end
end
