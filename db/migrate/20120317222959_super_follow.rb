class SuperFollow < ActiveRecord::Migration
  def up
    add_column :relationships, :super_follow, :boolean, :default => false
  end

  def down
    remove_column :relationships, :super_follow
  end
end
