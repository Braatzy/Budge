class UserMetaLevelData < ActiveRecord::Migration
  def self.up
    add_column :users, :meta_level_alignment, :integer
    add_column :users, :meta_level_role, :string
    add_column :users, :meta_level_name, :string
  end

  def self.down
    remove_column :users, :meta_level_alignment
    remove_column :users, :meta_level_role
    remove_column :users, :meta_level_name
  end
end
