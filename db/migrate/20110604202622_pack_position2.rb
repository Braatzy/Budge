class PackPosition2 < ActiveRecord::Migration
  def self.up
    add_column :packs, :position, :integer, :default => 1000
  end

  def self.down
    remove_column :packs, :position
  end
end
