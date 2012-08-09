class CreateTraits < ActiveRecord::Migration
  def self.up
    drop_table :traits
    create_table :traits do |t|
      t.string :token
      t.string :primary_pack_token
      t.string :element_token
      t.integer :do_charge, :default => 0
      t.string :do_name
      t.string :dont_name
      t.string :more_name
      t.string :less_name
      t.integer :parent_trait_id
      t.boolean :setup_required, :default => false
      t.text :setup_data
      t.integer :num_packs, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :traits
  end
end
