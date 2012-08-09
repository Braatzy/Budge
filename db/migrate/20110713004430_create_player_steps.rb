class CreatePlayerSteps < ActiveRecord::Migration
  def self.up
    create_table :player_steps do |t|
      t.integer :program_player_id
      t.integer :program_step_id
      
      # The step outcome, and when they were sorted there
      # ACT: Active
      # INC: Incomplete -> turns into ACT or LST (+)
      #      -> LST: Lost (+)
      # OUT: Dropped out
      # SNO: Snoozed
      # FAI: Failed
      # PRT: Partial Success
      # SUC: Full Success
      # SKP: Skipped
      t.string :outcome_token, :default => 'ACT'
      
      # The response token, relevant ID if applicable, and how who sorted them into this response
      # TBD: Not yet specified
      # STP: Go to step_id
      # BST: Go to the best child of this step_id
      # NEW: Create new step
      # REP: Repeat step
      # HEL: Help! Contact coach
      # COM: Contact player
      # PAU: Pause for X days
      # END: End program
      # REC: Recommend program_id      
      t.string :response_token, :default => 'TBD'
      t.integer :response_id      
      t.string :response_sorted_by, :default => 'auto' # other options "coach" and "player"
      # When changing this, make sure to also change self.program_player model

      t.timestamps
    end
  end

  def self.down
    drop_table :player_steps
  end
end
