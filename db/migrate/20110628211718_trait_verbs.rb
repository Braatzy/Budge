class TraitVerbs < ActiveRecord::Migration
  def self.up
    remove_column :traits, :more_name
    remove_column :traits, :less_name
    add_column :traits, :verb, :string
  end

  def self.down
    remove_column :traits, :verb
    add_column :traits, :more_name, :string
    add_column :traits, :less_name, :string
  end
end
