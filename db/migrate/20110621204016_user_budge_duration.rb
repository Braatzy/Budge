class UserBudgeDuration < ActiveRecord::Migration
  def self.up
    change_column :user_budges, :duration, :string
  end

  def self.down
    change_column :user_budges, :duration, :integer, :default => 1
  end
end
