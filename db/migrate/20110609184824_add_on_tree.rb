class AddOnTree < ActiveRecord::Migration
  def self.up
    add_column :addons, :parent_id, :integer
    add_column :addons, :purchasable, :boolean, :default => true
    add_column :addons, :description, :string
  end

  def self.down
    remove_column :addons, :parent_id
    remove_column :addons, :purchasable
    remove_column :addons, :description
  end
end

