class CreatePrompts < ActiveRecord::Migration
  def self.up
    create_table :prompts do |t|
      t.integer :prompt_type, :default => 0
      t.integer :program_id
      t.integer :program_step_id
      t.integer :position, :default => 1000
      t.integer :user_id
      t.string :deliver_via
      t.integer :status, :default => 0
      t.string :subject
      t.text :content
      t.integer :delivery_window, :default => 0
      t.integer :deliver_trigger, :default => 0
      t.integer :day_number
      t.integer :day_of_week_number

      t.timestamps
    end
    
    add_column :player_messages, :subject, :string
    add_column :player_messages, :prompt_id, :integer
  end

  def self.down
    drop_table :prompts
    remove_column :player_messages, :subject
    remove_column :player_messages, :prompt_id
  end
end
