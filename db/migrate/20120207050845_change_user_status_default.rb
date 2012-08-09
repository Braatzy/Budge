class ChangeUserStatusDefault < ActiveRecord::Migration
  def self.up
    change_column_default(:users, :status, 'interested')
  end

  def self.down
    change_column_default(:users, :status, 'unknown')
  end
end