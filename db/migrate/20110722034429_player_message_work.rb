class PlayerMessageWork < ActiveRecord::Migration
  def self.up 
    add_column :programs, :oauth_token_id, :integer
    add_column :program_players, :latest_tweet_id, :string
  end

  def self.down
    remove_column :programs, :oauth_token_id
    remove_column :program_players, :latest_tweet_id
  end
end
