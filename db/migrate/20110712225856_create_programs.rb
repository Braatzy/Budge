class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
    
      # Program details
      t.string :name
      t.text :description
      t.string :token # For the url
      t.string :group_token # For programs that are all the same, but with different coaches
      t.boolean :official, :default => false # Will show up in official program list
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.string :category_token
      t.boolean :system_program, :default => false
      t.string :adapted_from_name
      t.string :adapted_from_url
      t.text :active_message
      t.text :completed_message
      t.text :successful_message

      # Coach details
      t.integer :user_id
      t.boolean :contact_coach_frequently, :default => true

      # First step
      t.integer :program_step_id
      
      # Stat counts, from program_players
      # In order to judge most effective programs
      t.integer :total_players, :default => 0
      t.integer :num_active, :default => 0
      t.integer :num_incomplete, :default => 0
      t.integer :num_lost, :default => 0
      t.integer :num_dropped_out, :default => 0
      t.integer :num_snoozed, :default => 0
      t.integer :num_completed, :default => 0
      t.integer :num_victorious, :default => 0
      
      # Stat percentages
      t.decimal :percent_completed, :default => 0.0, :precision => 5, :scale => 2
      t.decimal :percent_successful, :default => 0.0, :precision => 5, :scale => 2
      t.decimal :avg_days_to_completion, :default => 0.0, :precision => 7, :scale => 2
      t.decimal :avg_days_to_victory, :default => 0.0, :precision => 7, :scale => 2
      t.integer :num_program_steps, :default => 0

      t.timestamps
    end    
  end

  def self.down
    drop_table :programs
  end
end
