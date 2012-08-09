class TraitRegexInfo < ActiveRecord::Migration
  def self.up
    add_column :traits, :name_regex, :string
    remove_column :traits, :setup_data
  end

  def self.down
    remove_column :traits, :name_regex, :string
    add_column :traits, :setup_data, :text
  end
end
