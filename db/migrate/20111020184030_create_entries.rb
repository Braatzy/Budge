class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer :user_id, :null => false
      t.integer :program_player_id, :null => false
      t.integer :program_id, :null => false
      t.integer :program_budge_id
      t.integer :player_message_id
      t.string :tweet_id
      t.string :facebook_post_id
      t.integer :location_context_id
      t.text :message
      t.string :message_type
      t.integer :privacy_setting, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
