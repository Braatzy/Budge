class RenameBehaviors < ActiveRecord::Migration
  def self.up
    rename_table :behaviors, :traits
    rename_table :pack_behaviors, :pack_traits
    
    rename_column :pack_traits, :behavior_id, :trait_id
    rename_column :packs, :num_behaviors, :num_traits

    rename_column :users, :num_concurrent_behaviors, :num_concurrent_traits
    rename_column :users, :max_concurrent_behaviors, :max_concurrent_traits

    rename_column :traits, :behavior_type, :trait_type
  end

  def self.down
    rename_table :traits, :behaviors
    rename_table :pack_traits, :pack_behaviors
    
    rename_column :pack_traits, :trait_id, :behavior_id
    rename_column :packs, :num_traits, :num_behaviors

    rename_column :users, :num_concurrent_traits, :num_concurrent_behaviors
    rename_column :users, :max_concurrent_traits, :max_concurrent_behaviors

    rename_column :behaviors, :trait_type, :behavior_type
  end
end
