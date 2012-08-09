class UserBudgeCredit < ActiveRecord::Migration
  def self.up
    add_column :users, :dollars_credit, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end

  def self.down
    remove_column :users, :dollars_credit
  end
end
