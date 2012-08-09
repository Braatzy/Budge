class LeaderStats < ActiveRecord::Migration
  def self.up
    add_column :leaders, :total, :decimal, :precision => 10, :scale => 3
    add_column :leaders, :average, :decimal, :precision => 10, :scale => 3
  end

  def self.down
    remove_column :leaders, :total
    remove_column :leaders, :average
  end
end
