class CreateLeaders < ActiveRecord::Migration
  def self.up
    create_table :leaders do |t|
      t.integer :program_id
      t.integer :user_id
      t.date :date
      t.decimal :score, :precision => 10, :scale => 3
      t.integer :num_days

      t.timestamps
    end
    add_index :leaders, [:program_id, :user_id, :date], :name => 'program_user_date'
  end

  def self.down
    drop_table :leaders
  end
end
