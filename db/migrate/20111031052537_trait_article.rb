class TraitArticle < ActiveRecord::Migration
  def self.up
    add_column :traits, :noun_pl, :string
    add_column :traits, :article, :string
  end

  def self.down
    remove_column :traits, :noun_pl
    remove_column :traits, :article
  end
end
