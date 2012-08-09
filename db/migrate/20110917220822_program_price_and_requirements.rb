class ProgramPriceAndRequirements < ActiveRecord::Migration
  def self.up
    add_column :programs, :price, :decimal, :precision => 6, :scale => 2
    add_column :programs, :requirements, :text
  end

  def self.down
    remove_column :programs, :price
    remove_column :programs, :requirements
  end
end
