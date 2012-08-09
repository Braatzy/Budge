class CreateNagModes < ActiveRecord::Migration
  def self.up
    create_table :nag_modes do |t|
      t.string :name
      t.text :description
      t.integer :num_days, :default => 7
      t.decimal :price, :precision => 5, :scale => 2, :default => 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :nag_modes
  end
end
