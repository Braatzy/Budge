class UserActionTemplate < ActiveRecord::Migration
  def self.up
    add_column :user_actions, :program_action_template_id, :integer
  end

  def self.down
    remove_column :user_actions, :program_action_template_id
  end
end
