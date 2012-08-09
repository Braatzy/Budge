class UserBudgeProgramData < ActiveRecord::Migration
  def self.up
    remove_column :user_budges, :budge_group_id
    remove_column :user_budges, :budge_set_id
    
    add_column :user_budges, :player_step_id, :integer
    add_column :user_budges, :program_step_id, :integer
    add_column :user_budges, :program_id, :integer
  end

  def self.down
    add_column :user_budges, :budge_group_id, :integer
    add_column :user_budges, :budge_set_id, :integer
    
    add_column :user_budges, :player_step_id
    add_column :user_budges, :program_step_id
    add_column :user_budges, :program_id
 end
end
