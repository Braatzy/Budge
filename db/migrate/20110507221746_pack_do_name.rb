class PackDoName < ActiveRecord::Migration
  def self.up
    rename_column :packs, :name, :do_name
    add_column :packs, :dont_name, :string
  end

  def self.down
    rename_column :packs, :do_name, :name
    remove_column :packs, :dont_name
  end
end
