class CreateUserNagModes < ActiveRecord::Migration
  def self.up
    remove_column :users, :nag_mode_id
    remove_column :users, :nag_mode_start_date
    remove_column :users, :nag_mode_end_date
    remove_column :users, :nag_mode_program_id
    create_table :user_nag_modes do |t|
      t.integer :user_id
      t.integer :nag_mode_id
      t.date :start_date
      t.date :end_date
      t.integer :program_id
      t.integer :program_player_id
      t.boolean :active, :default => true

      t.timestamps
    end
    add_index :user_nag_modes, [:start_date, :end_date, :active], :name => :date_index
  end

  def self.down
    drop_table :user_nag_modes
    add_column :users, :nag_mode_id, :integer
    add_column :users, :nag_mode_start_date, :date
    add_column :users, :nag_mode_end_date, :date
    add_column :users, :nag_mode_program_id, :integer
  end
end
