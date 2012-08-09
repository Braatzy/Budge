class CreateUserComments < ActiveRecord::Migration
  def self.up
    create_table :user_comments do |t|
      t.integer :user_id, :null => false
      t.integer :related_id, :null => false
      t.string :related_type, :null => false
      t.text :comment_text, :null => false

      t.timestamps
    end
    add_index :user_comments, [:user_id, :related_id, :related_type], :name => :user_related_id_type
  end

  def self.down
    drop_table :user_comments
  end
end
