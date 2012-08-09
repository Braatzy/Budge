class UserCommentsFromSystem < ActiveRecord::Migration
  def self.up
    add_column :user_comments, :comment_type, :string
    add_column :user_comments, :comment_type_id, :string
  end

  def self.down
    remove_column :user_comments, :comment_type
    remove_column :user_comments, :comment_type_id
  end
end
