class CreateBehaviors < ActiveRecord::Migration
  def self.up
    create_table :behaviors do |t|
      t.string :behavior_type
      t.string :token
      t.string :action
      t.string :question
      t.string :secondary_question
      t.integer :charge, :default => 0
      t.string :answer_type
      t.string :second_answer_type
      t.text :followup
      t.integer :num_packs, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :behaviors
  end
end
