class RemoveTraitIndex < ActiveRecord::Migration
  def self.up
    remove_index :traits, [:verb, :noun, :answer_type]
    add_index :traits, [:verb, :noun, :answer_type]
  end

  def self.down
    remove_index :traits, [:verb, :noun, :answer_type]
    add_index :traits, [:verb, :noun, :answer_type], :unique => true
  end
end
