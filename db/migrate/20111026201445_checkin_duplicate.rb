class CheckinDuplicate < ActiveRecord::Migration
  def self.up
    add_column :checkins, :duplicate, :boolean, :default => false
  end

  def self.down
    remove_column :checkins, :duplicate
  end
end
