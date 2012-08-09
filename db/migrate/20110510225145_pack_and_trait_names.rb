class PackAndTraitNames < ActiveRecord::Migration
  def self.up
    add_column :packs, :name, :string
    add_column :traits, :name, :string
  end

  def self.down
    remove_column :packs, :name
    remove_column :traits, :name
  end
end
