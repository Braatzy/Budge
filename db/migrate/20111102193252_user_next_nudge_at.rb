class UserNextNudgeAt < ActiveRecord::Migration
  def self.up
    add_column :users, :next_nudge_at, :datetime
  end

  def self.down
    remove_column :users, :next_nudge_at
  end
end
