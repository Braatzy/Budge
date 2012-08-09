class TraitPastTemplate < ActiveRecord::Migration
  def self.up
    add_column :traits, :past_template, :string
    add_column :traits, :hashtag, :string
  end

  def self.down
    remove_column :traits, :past_template
    remove_column :traits, :hashtag
  end
end
