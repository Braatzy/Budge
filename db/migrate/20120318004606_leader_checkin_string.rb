class LeaderCheckinString < ActiveRecord::Migration
  def up
    add_column :leaders, :checkin_string, :string
  end

  def down
    remove_column :leaders, :checkin_string
  end
end
