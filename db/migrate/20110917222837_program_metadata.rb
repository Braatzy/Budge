class ProgramMetadata < ActiveRecord::Migration
  def self.up
    add_column :programs, :company_name, :string
    add_column :programs, :company_url, :string
    add_column :programs, :first_published_on, :date
    add_column :programs, :last_published_on, :date
    add_column :programs, :program_version, :string
    add_column :programs, :avg_star_rating, :decimal, :precision => 3, :scale => 1
    add_column :programs, :maturity_rating, :string    
  end

  def self.down
    remove_column :programs, :company_name
    remove_column :programs, :company_url
    remove_column :programs, :first_published_on
    remove_column :programs, :last_published_on
    remove_column :programs, :program_version
    remove_column :programs, :avg_star_rating
    remove_column :programs, :maturity_rating
  end
end
