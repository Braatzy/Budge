class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.integer :checkin_id
      t.integer :user_id
      t.integer :num_points, :default => 0
      t.string :point_type
      t.integer :related_user_id
      t.integer :alignment
      t.boolean :do_trait
      t.integer :user_budge_id
      t.integer :trait_id

      t.timestamps
    end
    
    add_index :points, :checkin_id
    add_index :points, :user_budge_id
    add_index :points, :trait_id
    add_index :points, [:user_id, :related_user_id], :name => 'relationship'
  end

  def self.down
    drop_table :points
  end
end
