class TraitRefactor < ActiveRecord::Migration
  def self.up
  
    # Traits
    remove_column :traits, :specific_entity_type
    remove_column :traits, :do_alignment
    # --
    add_column :traits, :answer_type, :string
    add_column :traits, :daily_question, :string
    add_index :traits, [:verb, :noun, :answer_type], :unique => true
    
    # User Actions
    remove_column :user_actions, :alignment
    # --
    add_column :user_actions, :per_period, :integer, :default => 0
    
    # Program Action Templates
    add_column :program_action_templates, :daily_question, :string
    remove_column :program_action_templates, :alignment
    
    # Checkins
    add_column :checkins, :amount_units, :string
  end

  def self.down

    # Traits
    remove_column :traits, :answer_type, :string
    remove_column :traits, :daily_question
    remove_index :traits, [:verb, :noun, :answer_type]
    # --
    add_column :traits, :do_alignment, :integer, :default => 0
    add_column :traits, :specific_entity_type, :string
  
    # User Actions
    remove_column :user_action, :per_period
    # --
    add_column :user_actions, :alignment, :integer, :default => 0

    # Program Action Templates
    remove_column :program_action_templates, :daily_question
    add_column :program_action_templates, :alignment, :integer

    # Checkins
    remove_column :checkins, :amount_units
  end
end
