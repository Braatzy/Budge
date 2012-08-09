class CreateNagModePrompts < ActiveRecord::Migration
  def self.up
    create_table :nag_mode_prompts do |t|
      t.integer :nag_mode_id
      t.integer :day_number
      t.integer :at_hour
      t.boolean :at_wakeup_time, :default => false
      t.boolean :at_bedtime, :default => false
      t.string :via, :default => 'sms'
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :nag_mode_prompts
  end
end
