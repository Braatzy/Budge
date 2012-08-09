class UserTraitPoints < ActiveRecord::Migration
  def self.up
    add_column :user_traits, :do_points, :integer, :default => 0
    add_column :user_traits, :dont_points, :integer, :default => 0
    add_column :user_traits, :coach_do_points, :integer, :default => 0
    add_column :user_traits, :coach_dont_points, :integer, :default => 0
    
    add_index :points, [:user_id, :trait_id, :point_type, :do_trait], :name => 'user_trait_calculation'
  end

  def self.down
    remove_column :user_traits, :do_points
    remove_column :user_traits, :dont_points
    remove_column :user_traits, :coach_do_points
    remove_column :user_traits, :coach_dont_points
    
    remove_index :points, :name => 'user_trait_calculation'
  end
end
