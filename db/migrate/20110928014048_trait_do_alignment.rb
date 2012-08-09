class TraitDoAlignment < ActiveRecord::Migration
  def self.up
    rename_column :traits, :do, :do_alignment
  end

  def self.down
    rename_column :traits, :do_alignment, :do
  end
end
