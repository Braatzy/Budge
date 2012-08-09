class EntryParentid < ActiveRecord::Migration
  def self.up
    add_column :entries, :parent_id, :integer
  end

  def self.down
    remove_column :entries, :parent_id
  end
end
