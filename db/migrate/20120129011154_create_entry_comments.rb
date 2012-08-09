class CreateEntryComments < ActiveRecord::Migration
  def self.up
    create_table :entry_comments do |t|
      t.integer :entry_id
      t.integer :user_id
      t.integer :location_context_id
      t.text :message

      t.timestamps
    end
    
    add_index :entry_comments, [:entry_id]
    add_index :entries, [:user_id, :privacy_setting, :created_at], :name => 'user_privacy_timestamp'
  end

  def self.down
    drop_table :entry_comments
    remove_index :entries, [:user_id, :privacy_setting, :created_at], :name => 'user_privacy_timestamp'
  end
end
