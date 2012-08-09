class CreateUserBudges < ActiveRecord::Migration
  def self.up
    create_table :user_budges do |t|
      t.integer :user_id, :null => false
      t.boolean :system_budge, :default => false
      t.integer :budger_user_id
      t.string  :budge_species_token, :null => false
      t.integer :budge_species_level, :default => 1
      t.integer :trait_id
      t.integer :user_trait_id
      t.integer :num_supporters, :default => 0
      t.boolean :secret, :default => false
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :user_budges
  end
end
