class UserBudgeName < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :name, :string
  end

  def self.down
    remove_column :user_budges, :name
  end
end
