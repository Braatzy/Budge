class TraitSetupEntity < ActiveRecord::Migration
  def self.up
    add_column :traits, :specific_entity_type, :string
  end

  def self.down
    remove_column :traits, :specific_entity_type
  end
end
