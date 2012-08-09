class CreateUserLikes < ActiveRecord::Migration
  def self.up
    create_table :user_likes do |t|
      t.integer :user_id, :null => false
      t.integer :related_id, :null => false
      t.string :related_type, :null => false

      t.timestamps
    end
    
    add_index :user_likes, [:user_id, :related_id, :related_type], :name => :all_fields
  end

  def self.down
    drop_table :user_likes
  end
end
