class CreateStreamItems < ActiveRecord::Migration
  def self.up
    create_table :stream_items do |t|
      t.integer :user_id
      t.string :item_type
      t.integer :related_id
      t.integer :related_sub_id
      t.text :text
      t.text :data
      t.boolean :private, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_items
  end
end
