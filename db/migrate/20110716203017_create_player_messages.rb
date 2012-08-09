class CreatePlayerMessages < ActiveRecord::Migration
  def self.up
    create_table :player_messages do |t|
      t.integer :from_user_id
      t.string :from_remote_user
      t.integer :to_user_id
      t.string :to_remote_user
      t.text :content
      t.integer :program_player_id
      t.integer :player_step_id
      t.string :delivered_via
      t.string :remote_post_id
      t.text :message_data
      t.boolean :delivered, :default => false
      t.datetime :deliver_at
      t.boolean :from_coach, :default => false
      t.boolean :to_coach, :default => false
      t.boolean :has_context_trigger, :default => false
      t.text :context_trigger

      t.timestamps
    end
  end

  def self.down
    drop_table :player_messages
  end
end
