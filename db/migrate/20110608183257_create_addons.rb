class CreateAddons < ActiveRecord::Migration
  def self.up
    create_table :addons do |t|
      t.string :token
      t.string :name
      t.integer :visible_at_level, :default => 0
      t.boolean :auto_unlocked, :default => false
      t.integer :level_credit_cost, :default => 0
      t.decimal :dollar_cost, :precision => 6, :scale => 2, :default => 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :addons
  end
end
