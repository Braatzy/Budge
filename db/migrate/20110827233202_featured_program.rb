class FeaturedProgram < ActiveRecord::Migration
  def self.up
    add_column :programs, :featured, :boolean, :default => false
    add_column :programs, :require_email, :boolean, :default => false
    add_column :programs, :require_phone, :boolean, :default => false
    add_column :programs, :required_question_1, :string
    add_column :programs, :required_question_2, :string
    add_column :programs, :optional_question_1, :string
    add_column :programs, :optional_question_2, :string    
  end

  def self.down
    remove_column :programs, :featured
    remove_column :programs, :require_email
    remove_column :programs, :require_phone
    remove_column :programs, :required_question_1
    remove_column :programs, :required_question_2
    remove_column :programs, :optional_question_1
    remove_column :programs, :optional_question_2
  end
end
