class CreateTwitterScores < ActiveRecord::Migration
  def self.up
    create_table :twitter_scores do |t|
      t.date :date
      t.integer :twitter_id
      t.string :twitter_screen_name
      t.decimal :klout_score, :precision => 5, :scale => 2, :default => 0
      t.decimal :klout_slope, :precision => 5, :scale => 2, :default => 0
      t.integer :klout_class_id
      t.string :klout_class_name
      t.decimal :klout_network_score, :precision => 5, :scale => 2, :default => 0
      t.decimal :klout_amplification_score, :precision => 5, :scale => 2, :default => 0
      t.integer :klout_true_reach, :default => 0
      t.decimal :klout_delta_1day, :precision => 5, :scale => 2, :default => 0
      t.decimal :klout_delta_5day, :precision => 5, :scale => 2, :default => 0
      t.integer :num_followers, :default => 0
      t.integer :num_following, :default => 0
      t.integer :num_tweets, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_scores
  end
end
