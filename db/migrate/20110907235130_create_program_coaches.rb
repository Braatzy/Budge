class CreateProgramCoaches < ActiveRecord::Migration
  def self.up
    create_table :program_coaches do |t|
      t.integer :program_id
      t.integer :user_id
      t.integer :primary_oauth_token_id
      t.decimal :price, :precision => 6, :scale => 2, :default => 0.0
      t.text :message
      t.integer :total_players, :default => 0
      t.integer :num_active, :default => 0
      t.integer :num_incomplete, :default => 0
      t.integer :num_lost, :default => 0
      t.integer :num_dropped_out, :default => 0
      t.integer :num_snoozed, :default => 0
      t.integer :num_completed, :default => 0
      t.integer :num_victorious, :default => 0
      t.decimal :percent_complete, :precision => 5, :scale => 2, :default => 0
      t.decimal :percent_victorious, :precision => 5, :scale => 2, :default => 0
      t.decimal :avg_days_to_completion, :precision => 7, :scale => 2, :default => 0
      t.integer :avg_days_to_victory, :precision => 7, :scale => 2, :default => 0
      t.integer :avg_rating, :precision => 5, :scale => 2, :default => 0
      t.integer :level, :default => 1
      t.boolean :currently_accepting_applications, :default => false
      t.boolean :head_coach, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :program_coaches
  end
end
