class UpdatePoints < ActiveRecord::Migration
  def self.up
    remove_column :points, :alignment
    add_column :points, :pack_token, :string
  end

  def self.down
    add_column :points, :alignment, :integer, :default => 0
    remove_column :points, :pack_token
  end
end
