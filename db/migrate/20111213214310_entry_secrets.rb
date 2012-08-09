class EntrySecrets < ActiveRecord::Migration
  def self.up
    add_column :entries, :original_message, :string
    add_column :entries, :metadata, :text
  end

  def self.down
    remove_column :entries, :original_message
    remove_column :entries, :metadata
  end
end
