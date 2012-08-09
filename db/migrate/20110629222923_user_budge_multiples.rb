class UserBudgeMultiples < ActiveRecord::Migration
  def self.up
    add_column :user_budges, :custom_text, :string
    add_column :user_budges, :num_times_done, :integer, :default => 0
    add_column :traits, :object, :string
  end

  def self.down
    remove_column :user_budges, :custom_text
    remove_column :user_budges, :num_times_done
    remove_column :traits, :object
  end
end
