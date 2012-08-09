class UserActionCleanup < ActiveRecord::Migration
  def up
    remove_column :user_actions, :coach_user_id
    remove_column :user_actions, :note
    remove_column :user_actions, :num_comments
  end

  def down
    add_column :user_actions, :coach_user_id, :integer
    add_column :user_actions, :note, :text
    add_column :user_actions, :num_comments, :integer, :default => 0
  end
end
