class CreatePackBehaviors < ActiveRecord::Migration
  def self.up
    create_table :pack_behaviors do |t|
      t.integer :behavior_id, :null => false
      t.integer :pack_id, :null => false
      t.integer :level, :default => 1
      t.integer :position, :default => 1000

      t.timestamps
    end
  end

  def self.down
    drop_table :pack_behaviors
  end
end
