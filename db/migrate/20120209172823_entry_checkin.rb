class EntryCheckin < ActiveRecord::Migration
  def self.up
    add_column :entries, :checkin_id, :integer
  end

  def self.down
    remove_column :entries, :checkin_id
  end
end
