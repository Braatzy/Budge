class EntryDate < ActiveRecord::Migration
  def self.up
    add_column :entries, :date, :date
    add_column :entries, :player_budge_id, :integer
  end

  def self.down
    remove_column :entries, :date
    remove_column :entries, :player_budge_id
  end
end
