class ProgramPlayerAnswers < ActiveRecord::Migration
  def self.up
    add_column :program_players, :required_answer_1, :text
    add_column :program_players, :required_answer_2, :text
    add_column :program_players, :optional_answer_1, :text
    add_column :program_players, :optional_answer_2, :text
  end

  def self.down
    remove_column :program_players, :required_answer_1
    remove_column :program_players, :required_answer_2
    remove_column :program_players, :optional_answer_1
    remove_column :program_players, :optional_answer_2
  end
end
