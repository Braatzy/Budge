class CreatePacks < ActiveRecord::Migration
  def self.up
    create_table :packs do |t|
      t.integer :num_behaviors, :default => 0
      t.boolean :launched, :default => false
      t.boolean :public, :default => false
      t.boolean :requires_unlocking, :default => true
      t.string :name
      t.text :description
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :packs
  end
end
